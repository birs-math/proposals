class EditFlowService
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def query
    @country_code = Country.find_country_by_name(proposal.lead_organizer.country)
    @co_organizers = proposal.invites.where(invited_as: 'Co Organizer')
    @country_code_organizers = Country.find_country_by_name(@co_organizers.first.person.country)
    query = call_query
  end

  private

  def call_query
    <<END_STRING
            mutation {
              article: submitArticle(data: {
                authors: [{
                  email: "#{proposal.lead_organizer.email}"
                  givenName: "#{proposal.lead_organizer.firstname}"
                  familyName: "#{proposal.lead_organizer.lastname}"
                  nameInOriginalScript: "#{proposal.lead_organizer.fullname}"
                  institution: "#{proposal.lead_organizer.affiliation}"
                  countryCode: "#{@country_code.alpha2}"
                }, {
                  email: "#{@co_organizers.first.email}"
                  givenName: "#{@co_organizers.first.firstname}"
                  familyName: "#{@co_organizers.first.lastname}"
                  institution: "#{@co_organizers.first.person.affiliation}"
                  countryCode: "#{@country_code_organizers.alpha2}"
                  mrAuthorID: 12345
                }]
                correspAuthorEmail: "#{proposal.lead_organizer.email}"
                title: "#{proposal.title}"
                sectionAbbrev: "#{proposal.subject.code}"
                primarySubjects: {
                  scheme: "MSC2020"
                  codes: ["00-01"]
                }
                secondarySubjects: {
                  scheme: "MSC2020"
                  codes: ["00B05", "00A07"]
                }
                abstract: "#{proposal.title}"
                files: [{
                  role: "main"
                  key: "fileMain"
                }]
              }) {
                identifier
              }
            }
END_STRING
  end
end
