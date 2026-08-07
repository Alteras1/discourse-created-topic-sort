# frozen_string_literal: true

RSpec.describe "Created Topic Sort", type: :system do
  fab!(:category)
  fab!(:tag) { Fabricate(:tag, name: "mytag") }
  fab!(:topics) { Fabricate.times(3, :topic) }
  fab!(:category_topic) { Fabricate(:topic, category: category) }
  fab!(:tagged_topic) { Fabricate(:topic, tags: [tag]) }

  let!(:theme) { upload_theme_or_component }
  let(:discovery) { PageObjects::Pages::Discovery.new }

  describe "created column" do
    context "when on the home page" do
      it "shows the created column by default" do
        visit "/?order=created"
        expect(page).to have_css("th[data-sort-order='created']")
        expect(page).to have_css("td.created.age")
      end

      it "shows the created column when not sorted by created (enable_column_in_home_page default)" do
        visit "/"
        expect(page).to have_css("th[data-sort-order='created']")
      end

      it "hides the created column when enable_column_in_home_page is false" do
        theme.update_setting(:enable_column_in_home_page, false)
        theme.save!

        visit "/"
        expect(page).not_to have_css("th[data-sort-order='created']")
      end

      it "shows the created column when enable_column_in_home_page is false but order=created" do
        theme.update_setting(:enable_column_in_home_page, false)
        theme.save!

        visit "/?order=created"
        expect(page).to have_css("th[data-sort-order='created']")
      end
    end

    context "with enable_column_on_created_date_filter_only enabled" do
      before do
        theme.update_setting(:enable_column_on_created_date_filter_only, true)
        theme.save!
      end

      it "hides the created column when order is not 'created'" do
        visit "/"
        expect(page).not_to have_css("th[data-sort-order='created']")
      end

      it "shows the created column when order is 'created'" do
        visit "/?order=created"
        expect(page).to have_css("th[data-sort-order='created']")
        expect(page).to have_css("td.created.age.filter-created")
      end
    end

    context "in a category" do
      it "shows the created column in any category by default" do
        visit "/c/#{category.slug}/#{category.id}?order=created"
        expect(page).to have_css("th[data-sort-order='created']")
      end

      it "shows the created column only in the specified category" do
        other_category = Fabricate(:category)
        theme.update_setting(:categories_to_display_created_column, category.id.to_s)
        theme.save!

        visit "/c/#{category.slug}/#{category.id}"
        expect(page).to have_css("th[data-sort-order='created']")

        visit "/c/#{other_category.slug}/#{other_category.id}"
        expect(page).not_to have_css("th[data-sort-order='created']")
      end
    end

    context "with a tag" do
      before { SiteSetting.tagging_enabled = true }

      it "shows the created column on a tag page by default" do
        visit "/tag/#{tag.name}?order=created"
        expect(page).to have_css("th[data-sort-order='created']")
      end

      it "shows the created column only for the specified tag" do
        other_tag = Fabricate(:tag, name: "othertag")
        Fabricate(:topic, tags: [other_tag])
        theme.update_setting(:tags_to_display_created_column, tag.name)
        theme.save!

        visit "/tag/#{tag.name}"
        expect(page).to have_css("th[data-sort-order='created']")

        visit "/tag/#{other_tag.name}"
        expect(page).not_to have_css("th[data-sort-order='created']")
      end
    end
  end

  describe "navigation bar item" do
    it "shows the created date nav bar item by default" do
      visit "/"
      expect(page).to have_css("#navigation-bar .nav-item_created_date")
    end

    it "hides the nav bar item when enable_sort_by_created_date_nav_bar_item is false" do
      theme.update_setting(:enable_sort_by_created_date_nav_bar_item, false)
      theme.save!

      visit "/"
      expect(page).not_to have_css("#navigation-bar .nav-item_created_date")
    end

    it "navigates to ?order=created when the nav bar item is clicked" do
      visit "/"
      find("#navigation-bar .nav-item_created_date a").click
      expect(page).to have_current_path(/\?order=created/)
      expect(page).to have_css("#navigation-bar .nav-item_created_date.active")
    end

    it "hides the nav bar item on the home page when enable_nav_bar_item_in_home_page is false" do
      theme.update_setting(:enable_nav_bar_item_in_home_page, false)
      theme.save!

      visit "/"
      expect(page).not_to have_css("#navigation-bar .nav-item_created_date")
    end

    it "shows the nav bar item in a category regardless of enable_nav_bar_item_in_home_page" do
      theme.update_setting(:enable_nav_bar_item_in_home_page, false)
      theme.save!

      visit "/c/#{category.slug}/#{category.id}"
      expect(page).to have_css("#navigation-bar .nav-item_created_date")
    end

    context "with category restrictions" do
      it "shows the nav bar item only in the specified category" do
        other_category = Fabricate(:category)
        theme.update_setting(:categories_to_display_nav_bar_item, category.id.to_s)
        theme.save!

        visit "/c/#{category.slug}/#{category.id}"
        expect(page).to have_css("#navigation-bar .nav-item_created_date")

        visit "/c/#{other_category.slug}/#{other_category.id}"
        expect(page).not_to have_css("#navigation-bar .nav-item_created_date")
      end
    end

    context "with tag restrictions" do
      before { SiteSetting.tagging_enabled = true }

      it "shows the nav bar item only for the specified tag" do
        other_tag = Fabricate(:tag, name: "othertag2")
        Fabricate(:topic, tags: [other_tag])
        theme.update_setting(:tags_to_display_nav_bar_item, tag.name)
        theme.save!

        visit "/tag/#{tag.name}"
        expect(page).to have_css("#navigation-bar .nav-item_created_date")

        visit "/tag/#{other_tag.name}"
        expect(page).not_to have_css("#navigation-bar .nav-item_created_date")
      end
    end
  end
end
