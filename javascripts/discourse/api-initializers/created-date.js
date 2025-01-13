import { apiInitializer } from "discourse/lib/api";
import { longDate } from "discourse/lib/formatter";
import NavItem from "discourse/models/nav-item";
import I18n from "I18n";
import CreatedDateHeader from "../components/created-date-header";
import CreatedDateItem from "../components/created-date-item";
import CreatedDateMobileItem from "../components/created-date-mobile-item";

export default apiInitializer("1.38.0", (api) => {
  if (settings.enable_sort_by_created_date_nav_bar_item) {
    api.addNavigationBarItem({
      name: "created_date",
      displayName: I18n.t(themePrefix("filters.created_date.title")),
      title: I18n.t(themePrefix("filters.created_date.help")),
      before: "top",
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
      return I18n.t("topic.created_at", { date: longDate(this.createdAt) });
    },
  });

  api.registerValueTransformer("topic-list-columns", ({ value: cols }) => {
    cols.add("created", {
      header: CreatedDateHeader,
      item: CreatedDateItem,
    });
    return cols;
  });

  // outlet is only in mobile view
  api.renderInOutlet("topic-list-after-main-link", CreatedDateMobileItem);
});
