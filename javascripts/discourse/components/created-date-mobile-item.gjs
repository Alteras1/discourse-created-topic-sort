import Component from "@glimmer/component";
import { service } from "@ember/service";
import formatDate from "discourse/helpers/format-date";
import { relativeAge } from "discourse/lib/formatter";

export default class CreatedDateMobileItem extends Component {
  @service session;

  constructor() {
    super(...arguments);
  }

  get currentOrderIsCreated() {
    return this.session.topicList?.params.order === "created";
  }

  get showCreatedDate() {
    return (settings.enable_column_on_created_date_filter_only && this.currentOrderIsCreated)
            || !settings.enable_column_on_created_date_filter_only;
  }

  get createdBumpedSame() {
    const bumpedRel = relativeAge(this.args.outletArgs.topic.bumpedAt);
    const createdRel = relativeAge(this.args.outletArgs.topic.createdAt);
    const BUMPED_FORMAT = "YYYY-MM-DD";
    if (
      moment(this.args.outletArgs.topic.bumpedAt).isValid() &&
      moment(this.args.outletArgs.topic.createdAt).isValid()
    ) {
      const bumpedAtStr = moment(this.args.outletArgs.topic.bumpedAt).format(BUMPED_FORMAT);
      const createdAtStr = moment(this.args.outletArgs.topic.createdAt).format(BUMPED_FORMAT);
      return bumpedAtStr === createdAtStr && bumpedRel === createdRel;
    }
    return true;
  }

  <template>
  {{#if this.currentOrderIsCreated}}
    {{#unless this.createdBumpedSame}}
      <div class="topic-item-stats__mobile-created-date age" data-has-created>
        <a href={{@outletArgs.topic.lastPostUrl}}>{{formatDate
            @outletArgs.topic.bumpedAt
            format="tiny"
            noTitle="true"
          }}</a>
        /
        <a href={{@outletArgs.topic.firstPostUrl}}>{{formatDate
            @outletArgs.topic.createdAt
            format="tiny"
            noTitle="true"
          }}</a>
      </div>
    {{/unless}}
  {{/if}}
  </template>
}
