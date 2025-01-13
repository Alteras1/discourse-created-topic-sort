import { and, eq, not, or } from "truth-helpers";
import SortableColumn from "discourse/components/topic-list/header/sortable-column";

const CreatedDateHeader = <template>
  {{#if (or
          (and settings.enable_column_on_created_date_filter_only (eq @activeOrder "created"))
          (not settings.enable_column_on_created_date_filter_only)
        )}}
    <SortableColumn
      @sortable={{@sortable}}
      @number="true"
      @order="created"
      @activeOrder={{@activeOrder}}
      @changeSort={{@changeSort}}
      @ascending={{@ascending}}
      @name="created"
    />
  {{/if}}
</template>;

export default CreatedDateHeader;