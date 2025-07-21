import Component from "@glimmer/component";
import { getOwner } from "@ember/application";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import PluginOutlet from "discourse/components/plugin-outlet";
import concatClass from "discourse/helpers/concat-class";
import formatDate from "discourse/helpers/format-date";
import lazyHash from "discourse/helpers/lazy-hash";

export default class CreatedDateItem extends Component {
  @service router;
  @service site;

  get currentOrderIsCreated() {
    return this.router.currentRoute?.queryParams.order === "created";
  }

  get showCreatedDate() {
    return (
      (settings.enable_column_on_created_date_filter_only &&
        this.currentOrderIsCreated) ||
      !settings.enable_column_on_created_date_filter_only
    );
  }

  get mobileView() {
    const topicThumbnailService = getOwner(this).lookup(
      "service:topic-thumbnails"
    );
    if (
      topicThumbnailService?.get("displayBlogStyle") ||
      topicThumbnailService?.get("displayGrid") ||
      topicThumbnailService?.get("displayMasonry")
    ) {
      // if the topic thumbnails plugin is enabled and these styles are enabled
      // we want to display this created date field on mobile
      return false;
    }
    return this.site.mobileView;
  }

  <template>
    {{#unless this.mobileView}}
      {{#if this.showCreatedDate}}
        <td
          title={{htmlSafe @topic.createdAtTitle}}
          class={{concatClass
            "num topic-list-data created age"
            (if this.currentOrderIsCreated "filter-created")
          }}
        >
          <a href={{@topic.firstPostUrl}} class="post-activity">
            {{~! no whitespace ~}}
            <PluginOutlet
              @name="topic-list-before-relative-created-date"
              @outletArgs={{lazyHash topic=@topic}}
            />
            {{~formatDate @topic.createdAt format="tiny" noTitle="true"~}}
          </a>
        </td>
      {{/if}}
    {{/unless}}
  </template>
}
