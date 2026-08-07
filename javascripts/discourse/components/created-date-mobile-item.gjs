import Component from "@glimmer/component";
import { service } from "@ember/service";
import { relativeAge } from "discourse/lib/formatter";
import { and } from "discourse/truth-helpers";
import dFormatDate from "discourse/ui-kit/helpers/d-format-date";

export default class CreatedDateMobileItem extends Component {
  @service router;
  @service topicTrackingState;

  /**
   * Check if the current route is sorted by created date
   * @returns {boolean}
   *
   * This is a **UX decision** to only show the created date
   * in the topic list when the user is viewing the created date filter.
   * This is to avoid cluttering the mobile view with too much information.
   */
  get currentOrderIsCreated() {
    return this.router.currentRoute?.queryParams.order === "created";
  }

  get showCreatedDate() {
    if (
      settings.enable_column_on_created_date_filter_only &&
      !this.currentOrderIsCreated
    ) {
      return false;
    }

    const currentTag =
      this.router.currentRoute?.params?.tag_slug ||
      this.router.currentRoute?.params?.tag_name;

    if (currentTag) {
      if (settings.tags_to_display_created_column) {
        /** @type {string[]} */
        const allow_tags = settings.tags_to_display_created_column
          .split("|")
          .filter(Boolean);
        return allow_tags.includes(currentTag);
      }
      return true;
    }

    if (
      !this.topicTrackingState.filterCategory &&
      settings.enable_column_in_home_page
    ) {
      return true;
    }

    if (
      settings.categories_to_display_created_column &&
      this.topicTrackingState.filterCategory?.id
    ) {
      /** @type {number[]} */
      const allow_cat = settings.categories_to_display_created_column
        .split("|")
        .filter(Boolean)
        .map(Number);
      if (allow_cat.includes(this.topicTrackingState.filterCategory?.id)) {
        return true;
      }
    }

    return false;
  }

  get createdBumpedSame() {
    const bumpedAt = this.args.outletArgs.topic.bumpedAt;
    const createdAt = this.args.outletArgs.topic.createdAt;
    const bumpedDate = new Date(bumpedAt);
    const createdDate = new Date(createdAt);
    if (isNaN(bumpedDate) || isNaN(createdDate)) {
      return true;
    }
    const bumpedRel = relativeAge(bumpedAt);
    const createdRel = relativeAge(createdAt);
    return (
      bumpedDate.toDateString() === createdDate.toDateString() &&
      bumpedRel === createdRel
    );
  }

  <template>
    {{#if (and this.currentOrderIsCreated this.showCreatedDate)}}
      {{#unless this.createdBumpedSame}}
        <span
          class="topic-item-stats__mobile-created-date age"
          data-has-created
        >
          /
          <a href={{@outletArgs.topic.firstPostUrl}}>{{dFormatDate
              @outletArgs.topic.createdAt
              format="tiny"
              noTitle="true"
            }}</a>
        </span>
      {{/unless}}
    {{/if}}
  </template>
}
