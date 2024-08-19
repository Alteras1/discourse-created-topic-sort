import EmberObject from "@ember/object";
import { relativeAge } from "discourse/lib/formatter";
import discourseComputed from "discourse-common/utils/decorators";

export default class extends EmberObject {
  get mobileView() {
    return this.site.mobileView;
  }
  @discourseComputed("session.topicList")
  currentOrderIsCreated() {
    return this.session.topicList?.params.order === "created";
  }
  get createdBumpedSame() {
    const bumpedRel = relativeAge(this.topic.bumpedAt);
    const createdRel = relativeAge(this.topic.createdAt);
    const BUMPED_FORMAT = "YYYY-MM-DD";
    if (
      moment(this.topic.bumpedAt).isValid() &&
      moment(this.topic.createdAt).isValid()
    ) {
      const bumpedAtStr = moment(this.topic.bumpedAt).format(BUMPED_FORMAT);
      const createdAtStr = moment(this.topic.createdAt).format(BUMPED_FORMAT);
      return bumpedAtStr === createdAtStr && bumpedRel === createdRel;
    }
    return true;
  }
}
