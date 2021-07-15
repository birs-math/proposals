namespace :birs do
  task default: 'birs:birs_subjects'

  desc "Add BIRS Subjects to database"
  task birs_faqs: :environment do
    faqs = [
      {
        question: 'Why am I being asked to complete the Diversity and Inclusivity Survey?',
        answer: 'BIRS is committed to providing a welcoming environment to all participants at BIRS events. It is our goal to host workshops that are demographically diverse, and to foster opportunities for career growth and development that are inclusive to all.
								The collection of information from our participants is one way that BIRS supports this goal. This information enables us to see trends, improvements, and shortfalls in the diversity of our participants. Ultimately it provides data that can be used for evidence-based decision-making to promote greater inclusion and diversity within mathematics.',
        position: 1
      },
      {
        question: 'Who is required to complete the Diversity and Inclusivity Survey?',
        answer: 'Supporting organizers and participants invited to indicate their interest in a given proposal are required to complete the Diversity and Inclusivity Survey.
								While your response is mandatory, you have the option to select the “prefer not to answer” option for any/all of the questions if you choose not to self-identify. There is no penalty for selecting “prefer not to answer”.',
        position: 2

      },
      {
        question: 'As an organizer, will my answers impact the outcomes of the proposal, or any future proposals?',
        answer: 'No. Your answers on the Diversity and Inclusivity Survey are not used for assessing the merits of the proposal in anyway and are not shared with the reviewers. This survey is primarily about self-identification and there is no correct or incorrect answer.
								While there is an EDI (equity, diversity and inclusion) assessment element in the proposal evaluation, the requirements are outlined in the proposal guidelines and application. Assessment on this component will be made using the information provided solely in your proposal, not any information offered in the survey.',
        position: 3
      },
      {
        question: 'I do not want to answer these questions. What are my next steps?',
        answer: 'Taking part in this survey is a compulsory part of the application/participation process. However, we recognize that individuals may prefer not to share their responses to some questions. Each question has the option “Prefer not to answer”, which respondents are invited to use for any questions they feel uncomfortable answering.
								A survey that is answered by selecting “Prefer not to answer” for every answer will be considered a fully completed survey and meets the mandatory requirement.
								If you still have concerns about participating in the survey, you can contact the BIRS Program Coordinator at birs@birs.ca to discuss it further.',
        position: 4
      },
      {
        question: 'Are my answers anonymous or confidential?',
        answer: 'Your answers will only be used for its intended purposes and can only be viewed by members of the BIRS team on a need-to-know basis. The data may be shared with proposal applicants and reviewers at an aggregate level but this would not include any self-identifying information.',
        position: 5
      },
      {
        question: 'How is my data stored securely?',
        answer: "Your responses will be stored electronically upon submission. Your information will remain confidential, and will only be used or disclosed as authorized under the Freedom of Information Protection and Privacy Act (FIPPA) and The Banff Centre's privacy policy (if applicable). Should you have any questions about the collection or use of information, please contact the BIRS Program Coordinator at birs@birs.ca.",
        position: 6
      },
      {
        question: "Can I make changes to my questionnaire after it has been completed and submitted?",
        answer: "No. Due to the anonymous nature of the Diversity and Inclusion Survey, you will not be able to return to your previous responses for amendments. We also recognize that self-identification is not static and your responses may change over time based on your experience. Should you be invited as a supporting organizer or participant onto future BIRS proposals, you will have the opportunity to complete this survey again.",
        position: 7
      },
      {
        question: 'How do I fill in the questionnaire? How will I know that the questionnaire has been completed?',
        answer: 'Upon indicating your interest for a BIRS proposal, you will be automatically redirected to the Diversity and Inclusion Survey. The first page will provide a description of the survey’s purpose and a disclaimer, which notes that the completing survey is a mandatory step in the RSVP process. As mentioned, you are encouraged, but not required, to self-identify and responding with “Prefer not to answer” has no consequences or effect on a given proposal. To continue, check off the acknowledgement box and click “Submit Query” to view the survey.
								The survey consists of 9 questions related to self-identity. Questions 1 (country of citizenship) and 3 (ethnicity) allow for multiple selections – you can select all those that apply while pressing the “control” key on your keyboard. All other questions allow one selection only – you are encouraged to select the response that best describes yourself.
								Once you complete the questions, you can hit “Submit”, which will bring you to a confirmation page that thanks you for your response. You will not receive a confirmation email from your submission. At this point, you can close the survey window.',
        position: 8
      },
      {
        question: 'Why do you want to know about the demographics of your organizers and participants?',
        answer: 'BIRS is committed to providing a welcoming environment to all participants at BIRS events. It is our goal to host workshops that are demographically diverse, and to foster opportunities for career growth and development that are inclusive to all.
								The collection of information from our participants is one way that BIRS supports this goal. This information enables us to see trends, improvements, and shortfalls in the diversity of our participants. Ultimately it provides data that can be used for evidence-based decision-making to promote greater inclusion and diversity within mathematics.
								This is inline with the approach taken by Social Sciences and Humanities Research Council (SSHRC), the Natural Sciences and Engineering Research Council (NSERC), and the Canadian Institutes of Health Research (CIHR), among others. Science.gc.ca: Self-Identification Data Collection in Support of Equity, Diversity, and Inclusion is a great resource if you would like more insight into this policy.',
        position: 9
      },
      {
        question: 'I’ve filled this out before, why am I being asked to complete it again?',
        answer: 'The answers to the questionnaire are aggregated and associated with a specific proposal or workshop. To maintain confidentiality the information is not permanently attached to your personal profile. If you are applying to host or participate in an additional workshop, you will be prompted to fill this questionnaire again.',
        position: 10
      },
      {
        question: 'Why did you choose these questions? Why take a self-identification approach?',
        answer: 'The Diversity and Inclusivity Survey primarily focuses on 5 common dimensions to evaluate diversity; ethnicity, geographical diversity, sexual orientation, gender and disability. We recognise that diversity has many different markers, and we acknowledge that we have not covered them all explicitly here. These five markers were chosen because they are common across all attendees of BIRS, they represent groups that have traditionally been disproportionately under-represented in the mathematics community, and they are generally quantifiable, which is essential given the intended use of the data (to be used for evidence-based decision-making to promote greater inclusion and diversity within mathematics).
								It is also important to note there are no static definitions of race or ethnicity, and our understanding of gender and sexual orientation are evolving. While there are some commonly used definitions, these terms are socially constructed, multidimensional, and change over time. Self-identifying questions are used throughout the survey to ensure we capture the fullest picture of our participants, without limiting them to frameworks that may not accurately describe their experiences.',
        position: 11
      },
      {
        question: 'Can I identify in more than one group?',
        answer: 'Individuals are able and encouraged to self-identify for each of the questions in the survey. Some questions allow for multiple responses by selecting all those that apply while pressing the “control” key, while others may limit responses to one selection for data reportability reasons.',
        position: 12
      },
      {
        question: 'What do you mean by “gender”?',
        answer: 'The gender question prompts you to indicate the identity (or term) that best describes them at the present time. The question does not ask about sex assigned at birth or sexual orientation. “Gender” refers to the socially constructed roles, behaviours, expressions and identities of girls, women, boys, men and gender diverse people. It influences how people perceive themselves and each other, how they act and interact and the distribution of power and resources in society.
								Gender is usually conceptualized as a binary (girl/women and boy/man), yet there is considerable diversity in how individuals and groups understand, experience and express it. The response option provided in the self-identification form of “gender fluid and/or non-binary person” recognizes this diversity. “Gender fluid” refers to a person whose gender identity or expression changes or shifts along the gender spectrum. “Non-binary” refers to a person whose gender identity does not align with a binary understanding of gender such as man or woman.',
        position: 13
      },
      {
        question: 'What do you mean by 2SLGBTQIA+?',
        answer: 'Two Spirit, Lesbian, Gay, Bisexual, Trans, Queer (or Questioning), Intersex, Asexual (or sometimes Ally). The placement of Two Spirit (2S) first is to recognize that Indigenous people are the first peoples of this land and their understanding of gender and sexuality precedes colonization. The ‘+’ is for all the new and growing ways we become aware of sexual orientations and gender diversity.',
        position: 14
      },
      {
        question: 'What do you mean by Indigenous person?',
        answer: 'The Indigenous identity question whether you identify as an Indigenous person. This question is about personal identity, not legal status or registration. In Canada, the term ‘Indigenous’ encompasses First Nations, Métis and Inuit people, either collectively or separately, and is a preferred term in international usage, e.g., the ‘U.N. Declaration on the Rights of Indigenous Peoples.’ In its derivation from international movements, it is associated more with activism than government policy and so has emerged, for many, as the preferred term.
								It also encompasses all those who consider themselves indigenous to lands outside of the territories now known as Canada and the United States. Outside of Canada, you may indicate whether you identify as an indigenous in your country of origin or residence.',
        position: 15
      },
      {
        question: 'Does my disability count?',
        answer: 'The disability question prompts you to indicate if they identify as a person with a disability. The question refers to how the user personally identifies, not whether the user has ever qualified for a disability benefit under the Canada Pension Plan or other legally defined programs.
								A person with disability is someone who:
								Has a significant and persistent mobility, sensory, learning, or other physical or mental health impairment, which may be permanent or temporary;
								Experiences functional restrictions or limitations of their ability to perform the range of life’s activities; and/or
								May experience attitudinal and/or environmental barriers that hamper their full and self-directed participation in life.
								We recognize that barriers to inclusion are often related to a society’s norms, attitudes, and beliefs, rather than the capacity of the person.',
        position: 16
      },
      {
        question: 'I have a disability, impairment, or ongoing medical condition that might impact my participation. How can BIRS support my attendance?',
        answer: 'BIRS firmly believes that all attendees should be treated with respect and dignity and will make accommodations where possible to ensure that everyone is able to fully engage with the workshops, regardless of disability, impairment or medical conditions.
								Some practical steps might include working with the catering and hospitality team to ensure that there are appropriate food and accommodation options, or perhaps ensuring the location and contents of the workshops are accessible. It may involve providing information on the supports available in the vicinity of the conference, such as medical centers, even if those services are not provided directly by BIRS.
								If you are hoping to participate in a workshop but have concerns about how your participation will be supported, please email the BIRS Program Coordinator at birs@birs.ca to discuss accommodations that can be made to suit your unique needs.',
        position: 17
      },
      {
        question: 'What is an under-represented minority (URM)?',
        answer: 'The term URM is commonly used in reference to racial and ethnic populations, but it can also refer to other identities such as your gender or sexual identity.
								In this survey, we use the definition that an under-represented minority “is any group that is disproportionately represented relative to their numbers in the general population”. What may or may not be considered a minority will vary depending on the situation in question, and the population that it is relative to. For this reason, we have not included a strict definition of who is regarded as a minority, and instead ask people to self-identify given their knowledge and experience of their own circumstances.
								An example of the situational nature of minority status might be the prevalence of women in mathematics in Canada. They are not considered to be an URM in mathematics at the undergraduate level in Canada, but they could be considered underrepresented at the Honours level. Likewise, a Latinx mathematician working in Canada might self-identify as a member of an URM due to their ethnicity, while a Latinx mathematician in Mexico working in the same field may not.',
        position: 18
      }
    ]

    faqs.each do |faq|
      Faq.create(question: faq[:question], answer: faq[:answer])
    end
  end
end
