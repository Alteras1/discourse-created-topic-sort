import { render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import CreatedDateHeader from "../../discourse/components/created-date-header";

module(
  "Created Topic Sort | Integration | Component | CreatedDateHeader",
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.afterEach(function () {
      settings.enable_column_on_created_date_filter_only = false;
    });

    test("renders the sortable column when enable_column_on_created_date_filter_only is false", async function (assert) {
      settings.enable_column_on_created_date_filter_only = false;

      await render(
        <template>
          <table>
            <thead>
              <tr>
                <CreatedDateHeader
                  @sortable={{true}}
                  @activeOrder="activity"
                  @ascending={{false}}
                  @changeSort={{null}}
                />
              </tr>
            </thead>
          </table>
        </template>
      );

      assert
        .dom("th[data-sort-order='created']")
        .exists("renders the created column header when setting is disabled");
    });

    test("renders the sortable column when enable_column_on_created_date_filter_only is true and order is 'created'", async function (assert) {
      settings.enable_column_on_created_date_filter_only = true;

      await render(
        <template>
          <table>
            <thead>
              <tr>
                <CreatedDateHeader
                  @sortable={{true}}
                  @activeOrder="created"
                  @ascending={{false}}
                  @changeSort={{null}}
                />
              </tr>
            </thead>
          </table>
        </template>
      );

      assert
        .dom("th[data-sort-order='created']")
        .exists(
          "renders the created column header when order matches the filter"
        );
    });

    test("hides the sortable column when enable_column_on_created_date_filter_only is true and order is not 'created'", async function (assert) {
      settings.enable_column_on_created_date_filter_only = true;

      await render(
        <template>
          <table>
            <thead>
              <tr>
                <CreatedDateHeader
                  @sortable={{true}}
                  @activeOrder="activity"
                  @ascending={{false}}
                  @changeSort={{null}}
                />
              </tr>
            </thead>
          </table>
        </template>
      );

      assert
        .dom("th[data-sort-order='created']")
        .doesNotExist(
          "hides the created column header when order does not match the filter"
        );
    });
  }
);
