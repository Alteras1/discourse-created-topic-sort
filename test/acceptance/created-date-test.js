import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import { fixturesByUrl } from "discourse/tests/helpers/create-pretender";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

function tagTopicListFixture() {
  return {
    users: [{ id: 1, username: "sam", avatar_template: "/images/avatar.png" }],
    primary_groups: [],
    topic_list: {
      can_create_topic: true,
      draft: null,
      draft_key: "new_topic",
      per_page: 30,
      tags: [{ id: 1, name: "important", topic_count: 2, staff: false }],
      topics: [
        {
          id: 16,
          title: "Dinosaurs are the best",
          fancy_title: "Dinosaurs are the best",
          slug: "dinosaurs-are-the-best",
          posts_count: 1,
          reply_count: 0,
          highest_post_number: 1,
          image_url: null,
          created_at: "2019-11-12T05:19:52.300Z",
          last_posted_at: "2019-11-12T05:19:52.848Z",
          bumped: true,
          bumped_at: "2019-11-12T05:19:52.848Z",
          unseen: false,
          pinned: false,
          visible: true,
          closed: false,
          archived: false,
          tags: ["important"],
          views: 2,
          like_count: 0,
          has_summary: false,
          archetype: "regular",
          last_poster_username: "sam",
          category_id: 1,
          pinned_globally: false,
          posters: [
            {
              extras: "latest single",
              description: "Original Poster, Most Recent Poster",
              user_id: 1,
              primary_group_id: null,
            },
          ],
        },
        {
          id: 15,
          title: "This is a test tagged post",
          fancy_title: "This is a test tagged post",
          slug: "this-is-a-test-tagged-post",
          posts_count: 1,
          reply_count: 0,
          highest_post_number: 1,
          image_url: null,
          created_at: "2019-11-10T03:12:00.000Z",
          last_posted_at: "2019-11-11T05:19:32.516Z",
          bumped: true,
          bumped_at: "2019-11-11T05:19:32.516Z",
          unseen: false,
          pinned: false,
          visible: true,
          closed: false,
          archived: false,
          tags: ["important"],
          views: 5,
          like_count: 1,
          has_summary: false,
          archetype: "regular",
          last_poster_username: "sam",
          category_id: 1,
          pinned_globally: false,
          posters: [
            {
              extras: "latest single",
              description: "Original Poster, Most Recent Poster",
              user_id: 1,
              primary_group_id: null,
            },
          ],
        },
      ],
    },
  };
}

acceptance("Created Date - Nav Bar Item", function (needs) {
  needs.settings({ tagging_enabled: true });

  needs.pretender((server, helper) => {
    server.get("/tag/:tag_slug/:tag_id/l/latest.json", () => {
      return helper.response(tagTopicListFixture());
    });

    server.get("/tag/:tag_slug/:tag_id/notifications.json", () => {
      return helper.response({
        tag_notification: { id: 1, name: "important", notification_level: 1 },
      });
    });

    server.get("/tag/:tag_id/info.json", (request) => {
      return helper.response({
        tag_info: {
          id: parseInt(request.params.tag_id, 10) || 1,
          name: request.params.tag_id,
          slug: request.params.tag_id,
          topic_count: 2,
          staff: false,
          synonyms: [],
          tag_group_names: [],
          category_ids: [],
        },
        categories: [],
      });
    });
  });

  test("shows nav bar item on homepage by default", async function (assert) {
    await visit("/");
    assert
      .dom(".nav-item_created_date")
      .exists("nav bar item is present on homepage");
  });

  test("shows nav bar item in categories by default", async function (assert) {
    await visit("/c/bug/1");
    assert
      .dom(".nav-item_created_date")
      .exists("nav bar item is present in category");
  });

  test("shows nav bar item on tag pages by default", async function (assert) {
    await visit("/tag/important/1");
    assert
      .dom(".nav-item_created_date")
      .exists("nav bar item is present on tag page");
  });
});

acceptance("Created Date - Nav Bar Item Disabled", function (needs) {
  needs.settings({ tagging_enabled: true });

  test("hides nav bar item when setting is disabled", async function (assert) {
    settings.enable_sort_by_created_date_nav_bar_item = false;
    await visit("/");
    assert
      .dom(".nav-item_created_date")
      .doesNotExist("nav bar item is hidden when disabled");
  });
});

acceptance("Created Date - Nav Bar Item Homepage Disabled", function (needs) {
  needs.settings({ tagging_enabled: true });

  test("hides nav bar item on homepage when setting is disabled", async function (assert) {
    settings.enable_nav_bar_item_in_home_page = false;
    await visit("/");
    assert
      .dom(".nav-item_created_date")
      .doesNotExist("nav bar item is hidden on homepage");
  });

  test("still shows nav bar item in categories", async function (assert) {
    settings.enable_nav_bar_item_in_home_page = false;
    await visit("/c/bug/1");
    assert
      .dom(".nav-item_created_date")
      .exists("nav bar item still shows in category");
  });
});

acceptance("Created Date - Nav Bar Item Category Filter", function (needs) {
  needs.settings({ tagging_enabled: true });

  test("shows nav bar item only in allowed categories", async function (assert) {
    settings.categories_to_display_nav_bar_item = "1";
    await visit("/c/bug/1");
    assert
      .dom(".nav-item_created_date")
      .exists("nav bar item shows in allowed category (bug, id=1)");
  });

  test("hides nav bar item in non-allowed categories", async function (assert) {
    settings.categories_to_display_nav_bar_item = "99";
    await visit("/c/bug/1");
    assert
      .dom(".nav-item_created_date")
      .doesNotExist("nav bar item hidden in non-allowed category");
  });
});

acceptance("Created Date - Nav Bar Item Tag Filter", function (needs) {
  needs.settings({ tagging_enabled: true });

  needs.pretender((server, helper) => {
    server.get("/tag/:tag_slug/:tag_id/l/latest.json", () => {
      return helper.response(tagTopicListFixture());
    });

    server.get("/tag/:tag_slug/:tag_id/notifications.json", () => {
      return helper.response({
        tag_notification: { id: 1, name: "important", notification_level: 1 },
      });
    });

    server.get("/tag/:tag_id/info.json", (request) => {
      return helper.response({
        tag_info: {
          id: parseInt(request.params.tag_id, 10) || 1,
          name: request.params.tag_id,
          slug: request.params.tag_id,
          topic_count: 2,
          staff: false,
          synonyms: [],
          tag_group_names: [],
          category_ids: [],
        },
        categories: [],
      });
    });
  });

  test("shows nav bar item on allowed tag pages", async function (assert) {
    settings.tags_to_display_nav_bar_item = "important";
    await visit("/tag/important/1");
    assert
      .dom(".nav-item_created_date")
      .exists("nav bar item shows on allowed tag page");
  });

  test("hides nav bar item on non-allowed tag pages", async function (assert) {
    settings.tags_to_display_nav_bar_item = "other-tag";
    await visit("/tag/important/1");
    assert
      .dom(".nav-item_created_date")
      .doesNotExist("nav bar item hidden on non-allowed tag page");
  });
});

acceptance("Created Date - Column on Homepage", function (needs) {
  needs.settings({ tagging_enabled: true });

  test("shows created column on homepage by default", async function (assert) {
    await visit("/");
    assert
      .dom(".topic-list th.created")
      .exists("created column header is visible on homepage");
    assert
      .dom(".topic-list-item td.created")
      .exists("created column cell is visible on homepage");
  });

  test("hides created column on homepage when disabled", async function (assert) {
    settings.enable_column_in_home_page = false;
    await visit("/");
    assert
      .dom(".topic-list th.created")
      .doesNotExist("created column header is hidden on homepage");
  });
});

acceptance("Created Date - Column Only On Filter", function (needs) {
  needs.settings({ tagging_enabled: true });

  test("hides created column when not sorting by created and setting enabled", async function (assert) {
    settings.enable_column_on_created_date_filter_only = true;
    await visit("/");
    assert
      .dom(".topic-list th.created")
      .doesNotExist("created column hidden when not sorted by created");
  });

  test("shows created column when sorting by created", async function (assert) {
    settings.enable_column_on_created_date_filter_only = true;
    await visit("/latest?order=created");
    assert
      .dom(".topic-list th.created")
      .exists("created column shows when sorted by created");
  });
});

acceptance("Created Date - Column Category Filter", function (needs) {
  needs.settings({ tagging_enabled: true });

  test("shows created column in allowed categories", async function (assert) {
    settings.categories_to_display_created_column = "1";
    await visit("/c/bug/1");
    assert
      .dom(".topic-list th.created")
      .exists("created column shows in allowed category");
  });

  test("hides created column in non-allowed categories", async function (assert) {
    settings.categories_to_display_created_column = "99";
    await visit("/c/bug/1");
    assert
      .dom(".topic-list th.created")
      .doesNotExist("created column hidden in non-allowed category");
  });

  test("shows created column in all categories when setting is empty", async function (assert) {
    settings.categories_to_display_created_column = "";
    await visit("/c/bug/1");
    assert
      .dom(".topic-list th.created")
      .exists("created column shows when no restriction set");
  });
});

acceptance("Created Date - Column Tag Filter", function (needs) {
  needs.settings({ tagging_enabled: true });

  needs.pretender((server, helper) => {
    server.get("/tag/:tag_slug/:tag_id/l/latest.json", () => {
      return helper.response(tagTopicListFixture());
    });

    server.get("/tag/:tag_slug/:tag_id/notifications.json", () => {
      return helper.response({
        tag_notification: { id: 1, name: "important", notification_level: 1 },
      });
    });

    server.get("/tag/:tag_id/info.json", (request) => {
      return helper.response({
        tag_info: {
          id: parseInt(request.params.tag_id, 10) || 1,
          name: request.params.tag_id,
          slug: request.params.tag_id,
          topic_count: 2,
          staff: false,
          synonyms: [],
          tag_group_names: [],
          category_ids: [],
        },
        categories: [],
      });
    });
  });

  test("shows created column on allowed tag pages", async function (assert) {
    settings.tags_to_display_created_column = "important";
    await visit("/tag/important/1");
    assert
      .dom(".topic-list th.created")
      .exists("created column shows on allowed tag page");
  });

  test("hides created column on non-allowed tag pages", async function (assert) {
    settings.tags_to_display_created_column = "other-tag";
    await visit("/tag/important/1");
    assert
      .dom(".topic-list th.created")
      .doesNotExist("created column hidden on non-allowed tag page");
  });

  test("shows created column on all tag pages when setting is empty", async function (assert) {
    settings.tags_to_display_created_column = "";
    await visit("/tag/important/1");
    assert
      .dom(".topic-list th.created")
      .exists("created column shows on tag page when no restriction set");
  });
});

acceptance("Created Date - Sorting", function (needs) {
  needs.settings({ tagging_enabled: true });

  needs.pretender((server, helper) => {
    server.get("/latest.json", (request) => {
      const json = cloneJSON(fixturesByUrl["/latest.json"]);
      if (request.queryParams.order === "created") {
        json.topic_list.topics.sort(
          (a, b) => new Date(b.created_at) - new Date(a.created_at)
        );
      }
      return helper.response(json);
    });
  });

  test("clicking nav bar item navigates to created sort order", async function (assert) {
    await visit("/");
    await click(".nav-item_created_date a");
    assert
      .dom(".topic-list th.created")
      .exists("created column is visible after clicking nav item");
  });

  test("always shows created column when order=created regardless of settings", async function (assert) {
    settings.enable_column_in_home_page = false;
    settings.enable_column_on_created_date_filter_only = true;
    await visit("/latest?order=created");
    assert
      .dom(".topic-list th.created")
      .exists("created column shows when sorted by created");
  });
});
