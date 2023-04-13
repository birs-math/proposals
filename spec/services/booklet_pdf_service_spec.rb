require 'rails_helper'

RSpec.describe 'BookletPdfService' do
	before do
		@proposal = create(:proposal)
    @temp_file = 'Test temp_file'
    @input = 'all'
    @user = User.first
    @bps = BookletPdfService.new(@proposal.id, @temp_file, @input, @user)
  end

  it 'accepts a proposal' do
    expect(@bps.class).to eq(BookletPdfService)
  end

  describe '#multiple_booklet' do
    let!(:proposals) { create_list(:proposal, 3) }

    it "when table is table" do
      year = proposals.first.year
      expect(@bps.multiple_booklet("table", proposals)).to eq("\n\\thispagestyle{empty}\n\\begin{center}\n\\includegraphics[width=4in]{birs_logo.jpg}\\\\[30pt]\n{\\writeblue\\titlefont Banff International\\\\[10pt]\n                Research Station\\\\[0.5in]\n#{year} Proposals}\n\\end{center}\n\n\\newpage\n\n")
    end
  end

  describe '#multiple_booklet' do
    let!(:proposals) { create_list(:proposal, 3) }

    it "when table is toc" do
      expect(@bps.multiple_booklet("toc", proposals)).to eq("")
    end

    it "when table is ntoc" do
      expect(@bps.multiple_booklet("ntoc", proposals)).to eq("")
    end
  end
end
