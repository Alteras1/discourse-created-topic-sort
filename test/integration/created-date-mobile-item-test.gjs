import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import Topic from "discourse/models/topic";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import CreatedDateMobileItem from "../../discourse/components/created-date-mobile-item";

function makeOutletArgs(topicAttrs = {}) {
  const topic = Topic.create({
    id: 1,
    created_at: "2024-06-01T10:00:00Z",
    bumped_at: "2024-06-05T10:00:00Z",
    first_post_url: "/t/test/1/1",
    ...topicAttrs,
  });
  return { topic };
}

module(
  "Created Topic Sort | Integration | Component | CreatedDateMobileItem",
  function (hooks) {
    setupRenderingTest(hooks, { stubRouter: true });

    hooks.afterEach(function () {
      settings.enable_column_on_created_date_filter_only = false;
      settings.enable_column_in_home_page = true;
      settings.categories_to_display_created_column = "";
      settings.tags_to_display_created_column = "";
    });

    test("renders the created date when order is 'created' and bumped/created are on different days", async function (assert) {
      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "created" },
        params: {},
      };

      const outletArgs = makeOutletArgs({
        created_at: "2024-06-01T10:00:00Z",
        bumped_at: "2024-06-05T10:00:00Z",
      });

      await render(
        <template>
          <CreatedDateMobileItem @outletArgs={{outletArgs}} />
        </template>
      );

      assert
        .dom(".topic-item-stats__mobile-created-date")
        .exists("renders the created date when bumped and created differ");
    });

    test("does not render when bumped and created are on the same day", async function (assert) {
      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "created" },
        params: {},
      };

      const outletArgs = makeOutletArgs({
        created_at: "2024-06-01T08:00:00Z",
        bumped_at: "2024-06-01T18:00:00Z",
      });

      await render(
        <template>
          <CreatedDateMobileItem @outletArgs={{outletArgs}} />
        </template>
      );

      assert
        .dom(".topic-item-stats__mobile-created-date")
        .doesNotExist(
          "hides the created date when bumped and created are on the same day"
        );
    });

    test("does not render when order is not 'created'", async function (assert) {
      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "activity" },
        params: {},
      };

      const outletArgs = makeOutletArgs({
        created_at: "2024-06-01T10:00:00Z",
        bumped_at: "2024-06-05T10:00:00Z",
      });

      await render(
        <template>
          <CreatedDateMobileItem @outletArgs={{outletArgs}} />
        </template>
      );

      assert
        .dom(".topic-item-stats__mobile-created-date")
        .doesNotExist("hides the created date when order is not created");
    });

    test("does not render when enable_column_on_created_date_filter_only is false and enable_column_in_home_page is false (no category context)", async function (assert) {
      settings.enable_column_on_created_date_filter_only = false;
      settings.enable_column_in_home_page = false;

      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "created" },
        params: {},
      };

      const topicTrackingState = this.owner.lookup(
        "service:topic-tracking-state"
      );
      topicTrackingState.filterCategory = null;

      const outletArgs = makeOutletArgs({
        created_at: "2024-06-01T10:00:00Z",
        bumped_at: "2024-06-05T10:00:00Z",
      });

      await render(
        <template>
          <CreatedDateMobileItem @outletArgs={{outletArgs}} />
        </template>
      );

      assert
        .dom(".topic-item-stats__mobile-created-date")
        .doesNotExist(
          "hides the created date when column is not enabled in home page"
        );
    });

    test("renders the data-has-created attribute on the span", async function (assert) {
      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "created" },
        params: {},
      };

      const outletArgs = makeOutletArgs({
        created_at: "2024-06-01T10:00:00Z",
        bumped_at: "2024-06-05T10:00:00Z",
      });

      await render(
        <template>
          <CreatedDateMobileItem @outletArgs={{outletArgs}} />
        </template>
      );

      assert
        .dom(".topic-item-stats__mobile-created-date")
        .hasAttribute("data-has-created", "", "span has data-has-created attribute");
    });
  }
);
