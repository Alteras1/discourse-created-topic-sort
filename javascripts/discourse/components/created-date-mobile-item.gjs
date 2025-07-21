import Component from "@glimmer/component";
import { service } from "@ember/service";
import { and } from "truth-helpers";
import formatDate from "discourse/helpers/format-date";
import { relativeAge } from "discourse/lib/formatter";

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

    if (
      !this.topicTrackingState.filterCategory &&
      settings.enable_column_in_home_page
    ) {
      // assume homepage
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
    const bumpedRel = relativeAge(this.args.outletArgs.topic.bumpedAt);
    const createdRel = relativeAge(this.args.outletArgs.topic.createdAt);
    const BUMPED_FORMAT = "YYYY-MM-DD";
    if (
      moment(this.args.outletArgs.topic.bumpedAt).isValid() &&
      moment(this.args.outletArgs.topic.createdAt).isValid()
    ) {
      const bumpedAtStr = moment(this.args.outletArgs.topic.bumpedAt).format(
        BUMPED_FORMAT
      );
      const createdAtStr = moment(this.args.outletArgs.topic.createdAt).format(
        BUMPED_FORMAT
      );
      return bumpedAtStr === createdAtStr && bumpedRel === createdRel;
    }
    return true;
  }

  <template>
    {{#if (and this.currentOrderIsCreated this.showCreatedDate)}}
      {{#unless this.createdBumpedSame}}
        <span
          class="topic-item-stats__mobile-created-date age"
          data-has-created
        >
          /
          <a href={{@outletArgs.topic.firstPostUrl}}>{{formatDate
              @outletArgs.topic.createdAt
              format="tiny"
              noTitle="true"
            }}</a>
        </span>
      {{/unless}}
    {{/if}}
  </template>
}
