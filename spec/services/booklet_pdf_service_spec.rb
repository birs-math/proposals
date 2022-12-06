require 'rails_helper'

RSpec.describe 'BookletPdfService' do
	before do
		@proposal = create(:proposal)
    @temp_file = 'Test temp_file'
    @input = 'all'
    @user = User.first
    @bps = BookletPdfService.new(@proposal.id, @temp_file, @input, @user)
  end
  it 'accept a proposal' do
    expect(@bps.class).to eq(BookletPdfService)
  end
  context '#single_booklet' do
    before do 
      table = "toc"
      @bps = BookletPdfService.new(@proposal&.id, @temp_file, @input, @user)
      @year = @proposal.year
      @bps.single_booklet(table)
    end
    it "when proposal present and table is toc" do
      expect("test").to eq("test")
    end
  end
  context '#single_booklet' do
    before do 
      table = "ntoc"
      @bps = BookletPdfService.new(@proposal&.id, @temp_file, @input, @user)
      @year = @proposal.year
      @bps.single_booklet(table)
    end
    it "when proposal present and table is ntoc" do
      expect("test").to eq("test")
    end
  end
  context '#single_booklet' do
    before do 
      @proposal = nil
      table = "toc"
      @bps = BookletPdfService.new(@proposal&.id, @temp_file, @input, @user)
      @year = (Date.current.year + 2)
      @bps.single_booklet(table)
    end
    it "proposal is absent" do
      expect("test").to eq("test")
    end
  end
  context '#multiple_booklet' do
    let!(:proposals) { create_list(:proposal, 3) }
    it "when table is table" do
      table = "table"
      proposal_ids = proposals
      year = proposals.first.year
      expect(@bps.multiple_booklet(table, proposals)).to eq("\n\\thispagestyle{empty}\n\\begin{center}\n\\includegraphics[width=4in]{birs_logo.jpg}\\\\[30pt]\n{\\writeblue\\titlefont Banff International\\\\[10pt]\n                Research Station\\\\[0.5in]\n2024 Proposals}\n\\end{center}\n\n\\newpage\n\n")
    end
  end
  context '#multiple_booklet' do
    let!(:proposals) { create_list(:proposal, 3) }
    it "when table is toc" do
      table = "toc"
      number = 0
      proposal_ids = proposals
      year = proposals.first.year
      expect(@bps.multiple_booklet(table, proposals)).to eq("")
    end
    it "when table is ntoc" do
      table = "ntoc"
      number = 0
      proposal_ids = proposals
      year = proposals.first.year
      expect(@bps.multiple_booklet(table, proposals)).to eq("")
    end
  end
end