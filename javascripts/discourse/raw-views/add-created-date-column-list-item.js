import { getOwner } from "@ember/application";
import EmberObject from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";

export default class extends EmberObject {
  @discourseComputed("session.topicList")
  currentOrderIsCreated() {
    return this.session.topicList.params.order === "created";
  }
  get mobileView() {
    const topicThumbnailService = getOwner(this).lookup(
      "service:topic-thumbnails",
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
}
