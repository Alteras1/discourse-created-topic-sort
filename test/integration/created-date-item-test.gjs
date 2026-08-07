import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { forceMobile, resetMobile } from "discourse/lib/mobile";
import Topic from "discourse/models/topic";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import CreatedDateItem from "../../discourse/components/created-date-item";

function makeTopic(attrs = {}) {
  return Topic.create({
    id: 1,
    created_at: "2024-06-01T10:00:00Z",
    first_post_url: "/t/test/1/1",
    ...attrs,
  });
}

module(
  "Created Topic Sort | Integration | Component | CreatedDateItem",
  function (hooks) {
    setupRenderingTest(hooks, { stubRouter: true });

    hooks.beforeEach(function () {
      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: {},
      };
    });

    hooks.afterEach(function () {
      settings.enable_column_on_created_date_filter_only = false;
      resetMobile();
    });

    test("renders the created date cell on desktop", async function (assert) {
      settings.enable_column_on_created_date_filter_only = false;

      const topic = makeTopic();

      await render(
        <template>
          <table>
            <tbody>
              <tr>
                <CreatedDateItem @topic={{topic}} />
              </tr>
            </tbody>
          </table>
        </template>
      );

      assert
        .dom("td.created.age")
        .exists("renders the created date cell on desktop");
    });

    test("does not render on mobile view", async function (assert) {
      settings.enable_column_on_created_date_filter_only = false;
      forceMobile();

      const topic = makeTopic();

      await render(
        <template>
          <table>
            <tbody>
              <tr>
                <CreatedDateItem @topic={{topic}} />
              </tr>
            </tbody>
          </table>
        </template>
      );

      assert
        .dom("td.created.age")
        .doesNotExist("does not render created date cell on mobile");
    });

    test("hides the cell when enable_column_on_created_date_filter_only is true and order is not 'created'", async function (assert) {
      settings.enable_column_on_created_date_filter_only = true;

      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "activity" },
      };

      const topic = makeTopic();

      await render(
        <template>
          <table>
            <tbody>
              <tr>
                <CreatedDateItem @topic={{topic}} />
              </tr>
            </tbody>
          </table>
        </template>
      );

      assert
        .dom("td.created.age")
        .doesNotExist(
          "hides cell when filter-only setting is on and order is not created"
        );
    });

    test("shows the cell when enable_column_on_created_date_filter_only is true and order is 'created'", async function (assert) {
      settings.enable_column_on_created_date_filter_only = true;

      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "created" },
      };

      const topic = makeTopic();

      await render(
        <template>
          <table>
            <tbody>
              <tr>
                <CreatedDateItem @topic={{topic}} />
              </tr>
            </tbody>
          </table>
        </template>
      );

      assert
        .dom("td.created.age")
        .exists(
          "shows cell when filter-only setting is on and order is created"
        );
    });

    test("applies filter-created class when order is 'created'", async function (assert) {
      settings.enable_column_on_created_date_filter_only = false;

      const router = this.owner.lookup("service:router");
      router.currentRoute = {
        attributes: {},
        queryParams: { order: "created" },
      };

      const topic = makeTopic();

      await render(
        <template>
          <table>
            <tbody>
              <tr>
                <CreatedDateItem @topic={{topic}} />
              </tr>
            </tbody>
          </table>
        </template>
      );

      assert
        .dom("td.created.age.filter-created")
        .exists("applies filter-created class when order is created");
    });
  }
);
