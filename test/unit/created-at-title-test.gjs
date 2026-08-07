import { setupTest } from "ember-qunit";
import { module, test } from "qunit";
import { longDate } from "discourse/lib/formatter";
import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

module(
  "Created Topic Sort | Unit | Model | topic createdAtTitle getter",
  function (hooks) {
    setupTest(hooks);

    test("returns a formatted created-at title for a topic", function (assert) {
      const store = this.owner.lookup("service:store");

      withPluginApi((api) => {
        api.addModelGetter("topic", "createdAtTitle", function () {
          return i18n("topic.created_at", { date: longDate(this.createdAt) });
        });
      });

      const createdAt = "2024-03-15T10:30:00Z";
      const topic = store.createRecord("topic", {
        id: 1,
        created_at: createdAt,
      });

      assert.strictEqual(
        topic.createdAtTitle,
        i18n("topic.created_at", { date: longDate(topic.createdAt) }),
        "createdAtTitle returns the i18n formatted long date"
      );
    });

    test("createdAtTitle reflects the topic's actual createdAt value", function (assert) {
      const store = this.owner.lookup("service:store");

      withPluginApi((api) => {
        api.addModelGetter("topic", "createdAtTitle", function () {
          return i18n("topic.created_at", { date: longDate(this.createdAt) });
        });
      });

      const topic1 = store.createRecord("topic", {
        id: 2,
        created_at: "2023-01-01T00:00:00Z",
      });
      const topic2 = store.createRecord("topic", {
        id: 3,
        created_at: "2025-12-31T23:59:59Z",
      });

      assert.notStrictEqual(
        topic1.createdAtTitle,
        topic2.createdAtTitle,
        "different created_at values produce different titles"
      );
    });
  }
);
