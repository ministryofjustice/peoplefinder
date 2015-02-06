module Pages
  module Sections
    class Audit < SitePrism::Section
      elements :versions, 'tbody tr'
    end
  end
end
