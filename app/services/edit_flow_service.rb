class EditFlowService
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def proposal_country
    organizer_country = @proposal.lead_organizer.country
    raise "Lead Organizer has no country" if organizer_country.blank?

    find_country(@proposal.lead_organizer)
  end

  def find_country(organizer)
    country = Country.find_country_by_name(organizer&.country)
    if country.blank?
      raise "No match in Country database for Organizer #{organizer.fullname}
            country: #{organizer&.country}".squish
    end

    country
  end

  def organizer_country(invite)
    organizer = invite.person

    raise "Organizer #{organizer.fullname} has no country" if organizer.country.blank?

    find_country(organizer)
  end

  def supporting_organizers
    organizers = []
    @proposal.invites.where(invited_as: 'Organizer',
                            status: 'confirmed').each do |invite|
      country_code = organizer_country(invite)&.alpha2
      organizers << [invite.person, country_code]
    end
    organizers
  end

  def co_authors
    supporting_organizers&.each_with_object('') do |org_data, text|
      organizer, country_code = org_data
      text << %({
                      emailAddress: {
                        address: "#{organizer.email}"
                      }
                      nameGiven: "#{organizer.firstname}"
                      nameSurname: "#{organizer.lastname}"
                      institutionAtSubmission: {
                        name: "#{organizer.affiliation}"
                      }
                      countryAtSubmission: {
                        codeAlpha2: "#{country_code}"
                      }
                    },)
    end
  end

  def proposal_abstract
    # get the proposal's Press Release field?
    ''
  end

  def ams_subject_code(code)
    title = @proposal.ams_subjects.send(code)&.title
    raise "#{@proposal&.code} has missing AMS Subject code" if title.blank?

    "#{title[/^\d+/]}-XX"
  end

  def query
    <<END_STRING
            mutation {
              article: submitArticle(
                submission: {
                  section: {
                    code: "#{@proposal.subject.code}"
                  }

                  title: "#{@proposal.code}: #{@proposal.title}"
                  abstract: "#{proposal_abstract}"

                  emailAddressCorrespAuthor: {
                    address: "#{@proposal.lead_organizer.email}"
                  }

                  authors: [
                    {
                      emailAddress: {
                        address: "#{@proposal.lead_organizer.email}"
                      }
                      nameFull: "#{@proposal.lead_organizer.fullname}"
                      nameGiven: "#{@proposal.lead_organizer.firstname}"
                      nameSurname: "#{@proposal.lead_organizer.lastname}"
                      institutionAtSubmission: {
                        name: "#{@proposal.lead_organizer.affiliation}"
                      }
                      countryAtSubmission: {
                        codeAlpha2: "#{find_country(@proposal.lead_organizer).alpha2}"
                      }
                    },
                    #{co_authors}
                  ]

                  subjectsPrimary: {
                    scheme: "MSC2020"
                    subjects: [
                      {code: "#{ams_subject_code(:first)}"}
                    ]
                  }

                  subjectsSecondary: {
                    scheme: "MSC2020"
                    subjects: [
                      {code: "#{ams_subject_code(:last)}"}
                    ]
                  }

                  articleDocumentUploads: [
                    {
                      role: "main"
                      multipartFormName: "fileMain"
                    }
                  ]
                }
              ) {
                id
              }
            }
END_STRING
  end

  def mutation
    <<END_STRING
            query {
              article(id: "#{@proposal&.editflow_id}") {
                  id
                  identifier
                  reviewVersionLatest {
                      number
                      docMain {
                          role
                          fileID
                      }
                      docsAll {
                          role
                          fileID
                      }
                      reviews {
                          reviewer {
                              nameFull
                          }
                          isQuick
                          dateRequested
                          status {
                              code
                              description
                          }
                          score
                          reviewVersion {
                              number
                          }
                          reports {
                              fileID
                              nickname
                              canShareWith {
                                  authors
                              }
                              dateReported
                              reviewer {
                                  nameFull
                              }
                              review {
                                  dateRequested
                              }
                              reviewVersion {
                                  number
                              }
                              article {
                                  identifier
                              }
                          }
                          article {
                              identifier
                          }
                      }
                      article {
                          identifier
                      }
                  }
                  reviewVersions {
                      number
                  }
              }
          }
END_STRING
  end

  def file_url(file_id)
    <<END_STRING
            mutation {
              fileURL: fileURLPublicWithLifetime(
                  fileID: "#{file_id}"
                  expiresAfterSeconds: 120
                  accessLimit: 1
              ) {
                  fileID
                  url
                  dateExpires
                  accessLimit
              }
            }
END_STRING
  end

  def revise_article
    <<END_STRING
            mutation {
              articleReviewVersion: reviseArticle(
                revision: {
                  articleID: "#{@proposal.editflow_id}"
                  mainMultipartFormName: "fileMain"
                  revisionLetterMultipartFormName: "fileRevisionLetter"
                }
              ) {
                id
                number
                docMain {
                  fileID
                  role
                }
                docsAll {
                  fileID
                  role
                }
                article {
                  id
                  identifier
                  title
                }
              }
            }
END_STRING
  end
end
