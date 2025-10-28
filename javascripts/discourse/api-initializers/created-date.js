import { apiInitializer } from "discourse/lib/api";
import { longDate } from "discourse/lib/formatter";
import NavItem from "discourse/models/nav-item";
import { i18n } from "discourse-i18n";
import CreatedDateHeader from "../components/created-date-header";
import CreatedDateItem from "../components/created-date-item";
import CreatedDateMobileItem from "../components/created-date-mobile-item";

export default apiInitializer("1.38.0", (api) => {
  if (settings.enable_sort_by_created_date_nav_bar_item) {
    api.addNavigationBarItem({
      name: "created_date",
      displayName: i18n(themePrefix("filters.created_date.title")),
      title: i18n(themePrefix("filters.created_date.help")),
      before: settings.nav_bar_item_before,
      customFilter: (category) => {
        if (!category) {
          return settings.enable_nav_bar_item_in_home_page;
        }

        /** @type number[] */
        const allow_cat = settings.categories_to_display_nav_bar_item
          .split("|")
          .filter(Boolean)
          .map(Number);
        if (allow_cat.length) {
          return allow_cat.includes(category.id);
        }
        return true;
      },
      customHref: (category, args) => {
        const path = NavItem.pathFor("latest", args);
        return `${path}?order=created`;
      },
      forceActive: (category, args, router) => {
        const currentRoute = router.currentRoute;
        return (
          currentRoute.attributes.filterType === "latest" &&
          currentRoute.queryParams?.order === "created"
        );
      },
    });
  }

  api.modifyClass("model:topic", {
    pluginId: "created-date",
    get createdAtTitle() {
      return i18n("topic.created_at", { date: longDate(this.createdAt) });
    },
  });

  api.registerValueTransformer(
    "topic-list-columns",
    ({ value: cols, context }) => {
      const createdCol = {
        header: CreatedDateHeader,
        item: CreatedDateItem,
      };

      const router = api.container.lookup("service:router");
      if (router.currentRoute?.queryParams?.order === "created") {
        cols.add("created", createdCol);
        return cols;
      }

      if (!context.category) {
        // no category context, assume we are in home page
        if (settings.enable_column_in_home_page) {
          cols.add("created", createdCol);
        }
        return cols;
      }

      // category context
      if (settings.categories_to_display_created_column) {
        /** @type {number[]} */
        const allow_cat = settings.categories_to_display_created_column
          .split("|")
          .filter(Boolean)
          .map(Number);
        if (allow_cat.includes(context.category.id)) {
          cols.add("created", createdCol);
        }
      } else {
        // restrictions not set, display in all categories
        cols.add("created", createdCol);
      }
      return cols;
    }
  );

  // outlet is only in mobile view
  api.renderInOutlet(
    "topic-list-item-mobile-bumped-at__after",
    CreatedDateMobileItem
  );
});
