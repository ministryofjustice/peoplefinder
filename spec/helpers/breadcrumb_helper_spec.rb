require "rails_helper"

RSpec.describe BreadcrumbHelper, type: :helper do
  describe "#breadcrumbs" do
    let(:hrbp) { create(:group, parent: hr, name: "Human Resources Business Partners", acronym: "HRBP") }
    let(:hr) { create(:group, parent: csg, name: "Human Resources", acronym: "HR") }
    let(:csg) { create(:group, parent: moj, name: "Corporate Services Group", acronym: "CSG") }
    let(:moj) { create(:department, acronym: "MOJ") }

    it "builds linked breadcrumbs" do
      justice = create(:department)
      digital_service = create(:group, parent: justice, name: "Digital Services")
      generated = breadcrumbs([justice, digital_service])
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="/teams/ministry-of-justice"]', text: "Ministry of Justice")
      expect(fragment).to have_selector('a[href="/teams/digital-services"]', text: "Digital Services")
    end

    it "builds linked breadcrumbs only showing acronyms for first two levels" do
      generated = breadcrumbs([moj, csg, hr, hrbp])
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="/teams/ministry-of-justice"]', text: "MOJ")
      expect(fragment).to have_selector('a[href="/teams/corporate-services-group"]', text: "CSG")
      expect(fragment).to have_selector('a[href="/teams/human-resources"]', text: "HR")
      expect(fragment).to have_selector('a[href="/teams/human-resources-business-partners"]', text: "Human Resources Business Partners")
    end

    it "builds linked breadcrumbs only showing acronyms for first two levels when Home path at front of breadcrumbs" do
      generated = breadcrumbs(Home.path + [moj, csg, hr, hrbp])
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="/teams/ministry-of-justice"]', text: "MOJ")
      expect(fragment).to have_selector('a[href="/teams/corporate-services-group"]', text: "CSG")
      expect(fragment).to have_selector('a[href="/teams/human-resources"]', text: "HR")
      expect(fragment).to have_selector('a[href="/teams/human-resources-business-partners"]', text: "Human Resources Business Partners")
    end

    it "builds linked breadcrumbs only showing acronyms for first two levels when root team not at front of breadcrumbs" do
      generated = breadcrumbs([csg, hr, hrbp])
      fragment = Capybara::Node::Simple.new(generated)
      expect(fragment).to have_selector('a[href="/teams/corporate-services-group"]', text: "CSG")
      expect(fragment).to have_selector('a[href="/teams/human-resources"]', text: "HR")
      expect(fragment).to have_selector('a[href="/teams/human-resources-business-partners"]', text: "Human Resources Business Partners")
    end
  end

  describe "#link_to_breadcrumb_name_unless_current" do
    context "with an object that has a short name" do
      let(:obj) { instance_double(Group, name: "Full Name", short_name: "FN") }

      it "links to the object" do
        expect(self).to receive(:link_to_unless_current)
          .with(anything, obj, anything)
        link_to_breadcrumb_name_unless_current(obj, 1)
      end

      it "uses short name for the link text if index is < 2" do
        expect(self).to receive(:link_to_unless_current)
          .with("FN", anything, anything)
        link_to_breadcrumb_name_unless_current(obj, 1)
      end

      it "uses full name for the link text if index is >= 2" do
        expect(self).to receive(:link_to_unless_current)
          .with("Full Name", anything, anything)
        link_to_breadcrumb_name_unless_current(obj, 2)
      end

      it "uses full name for the link title" do
        expect(self).to receive(:link_to_unless_current)
          .with(anything, anything, title: "Full Name")
        link_to_breadcrumb_name_unless_current(obj, 1)
      end
    end

    context "with an object that has an empty short name" do
      let(:obj) { instance_double(Group, name: "Full Name", short_name: "") }

      it "links to the object" do
        expect(self).to receive(:link_to_unless_current)
          .with(anything, obj, anything)
        link_to_breadcrumb_name_unless_current(obj, 1)
      end

      it "uses full name for the link text" do
        expect(self).to receive(:link_to_unless_current)
          .with("Full Name", anything, anything)
        link_to_breadcrumb_name_unless_current(obj, 1)
      end

      it "has no link title" do
        expect(self).to receive(:link_to_unless_current)
          .with(anything, anything, {})
        link_to_breadcrumb_name_unless_current(obj, 1)
      end
    end

    context "with an object that has no short name" do
      let(:obj) { instance_double(Group, name: "Full Name") }

      it "links to the object" do
        expect(self).to receive(:link_to_unless_current)
          .with(anything, obj, anything)
        link_to_breadcrumb_name_unless_current(obj, 1)
      end

      it "uses full name for the link text" do
        expect(self).to receive(:link_to_unless_current)
          .with("Full Name", anything, anything)
        link_to_breadcrumb_name_unless_current(obj, 1)
      end

      it "has no link title" do
        expect(self).to receive(:link_to_unless_current)
          .with(anything, anything, {})
        link_to_breadcrumb_name_unless_current(obj, 1)
      end
    end
  end
end
