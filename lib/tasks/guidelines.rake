namespace :birs do
  desc "Edit guidelines"
  task guidelines: :environment do
    guideline =
      '<div>
        <p>Please read the descriptions of our various <a href="/programs">programs</a> before preparing your proposal. Proposals should be submitted using the <a href="https://www.birs.ca/proposals/">online form</a>.</p>
        <p>Please indicate the subject area of your proposal. If the codes are not adequate (particularly for emerging fields), use “Other” and specify in the “Additional Comments” field.</p>
        <p>We follow the Tri-Agency’s Action Plan on EDI, available here:</p>
        <p><a href="https://www.nserc-crsng.gc.ca/NSERC-CRSNG/EDI-EDI/Action-Plan_Plan-dAction_eng.asp">https://www.nserc-crsng.gc.ca/NSERC-CRSNG/EDI-EDI/Action-Plan_Plan-dAction_eng.asp  </a></p>
        <p><a href="https://www.nserc-crsng.gc.ca/NSERC-CRSNG/EDI-EDI/Dimensions_Dimensions_eng.asp">https://www.nserc-crsng.gc.ca/NSERC-CRSNG/EDI-EDI/Dimensions_Dimensions_eng.asp</a></p>
        <p></p>
        <p>For ideas and resources on crafting an EDI positive program, please refer to:
          <a href="https://www.birs.ca/about/governance/scientific-management/Equity-Diversity-Inclusion-Board/resources-for-EDI">Resources for Equity, Diversity and Inclusion</a>
        </p>
        <div data-controller="guidelines">
          <h4 id="organizing_committee"> <a href="guidelines#organizing_committee" data-action="mouseup->guidelines#copy" value="organizing_committee"><i class="align-middle me-2 fas fa-fw fa-link" value="/guidelines#organizing_committee " ></i></a> 1. Organizing committee</h4>
        </div>
        <div class="ms-5">
          <p>For a 5-day workshop, we require a minimum of two and a maximum of five organizers per proposal, and allow only one organizer per institution. Additional organizers may be listed in the "Comments" section, if needed. Please provide reasons for such additions. One of the organizing committee members should be designated as the main Contact Organizer. All organizers are expected to be on-site during the delivery of their program and participate actively in the execution of the event.</p>
          <p>In accordance with BIRS’s mandate to promote equity, diversity and inclusion (EDI), we <b>strongly recommend</b> an organizing committee to include:</p>
          <p>(A) at least one early-career researcher within ten years of their doctoral degree at the time of submission of the proposal, and</p>
          <p>(B) at least one self-identified member(organizing committee of 2) or at least two self-identified members(organizing committee of 3 and more) from communities under-represented in STEM disciplines. This includes, but need not be limited to, women, Indigenous Peoples, persons with disabilities, members of visible minorities/racialized groups, and members of LGBTQ2+ communities.</p>
          <p>Note: </p>
          <ol type="i">
            <li> An organizer can be counted towards both (A) and (B) if they satisfy both descriptions.</li>
            <li>An organizing committee need not disclose any information that could be used to identify a specific member or an under-represented community. They may instead report the aggregate percentage in the organizing committee from under-represented groups without identifying any specific groups. </li>
            <li>An organizing committee that does not report its demographic composition or whose composition does not meet the recommendations stated above is still eligible to submit an application. However we request such a proposal to explicitly address how the proposed program will include and support under-represented groups to meet BIRSs standards of EDI. We hope that applicants will take this as an invitation to look closely at their own research field and assess how it might be made more inclusive.</li>
          </ol>
        </div>
        <div data-controller="guidelines">
          <h4 id="dates"> <a href="guidelines#dates" data-action="mouseup->guidelines#copy" value="dates"><i class="align-middle me-2 fas fa-fw fa-link" value="/guidelines#dates " ></i></a> 2. Dates</h4>
        </div>
        <div class="ms-5">
          <p>With regard to your proposed dates, please give us options – particularly “low-season” alternatives! You may use the link <a href="https://www.calendarlabs.com/online-calendar/2020-calendar/canada-holidays/">https://www.calendarlabs.com/online-calendar/2020-calendar/canada-holidays/</a> for a list of holidays to make sure that the dates you indicate as being acceptable really are acceptable to you.</p>
        </div>
        <div data-controller="guidelines">
          <h4 id="proposal_content"> <a href="guidelines#proposal_content" data-action="mouseup->guidelines#copy" value="proposal_content"><i class="align-middle me-2 fas fa-fw fa-link" value="/guidelines#proposal_content" ></i></a>3. Proposal content</h4>
        </div>
        <div class="ms-5">
          <p>1. The workshop should be sufficiently innovative and timely that holding it has the potential to make a difference to the subject. Of special interest are proposals that take advantage of newly emerging links between areas, explore synergies between evolving fields or offer meeting opportunities for groups of participants who do not normally meet together.</p>
          <p>2. Proposals must include contingency planning for situations similar to the COVID-19 pandemic. Priority will be given to proposals that demonstrate adaptability to virtual or online models under such circumstances.</p>
          <p>3. At least some of the organizers should have recognized international stature as leaders in their fields.</p>
          <p>4. The proposed participant list should be realistic and coherent with the goals of the event. It is more convincing to the selection panel if you can indicate that a number of your participants have confirmed their interest in the workshop.</p>
          <p>5. The proposed and the final list of participants must ensure adequate representation of scientists from all career stages, and meet BIRS’s commitment to ensuring diversity in the broadest sense, across race, gender, ethnicity, visible and invisible disabilities, institution and geographic location. Please refer to the Canadian Tri-Agency statement and related links on equity, diversity and inclusion (EDI):</p>
          <p><a href="https://www.nserc-crsng.gc.ca/NSERC-CRSNG/EDI-EDI/index_eng.asp">https://www.nserc-crsng.gc.ca/NSERC-CRSNG/EDI-EDI/index_eng.asp</a></p>
          <p>and outline an action plan how the proposed participant list will fulfill this mandate. An EDI statement with specific participation targets and a strategy for meeting these targets will be helpful in this regard.</p>
          <p>6. The proposal should avoid being too diffuse and should not attempt to cover too many areas at once. If applicable, indicate why it is distinct from other events in related areas being held elsewhere.</p>
          <p>7. The proposal should indicate detailed planning for program delivery, and embed a variety of events in addition to the traditional meeting format. We intend to host events that facilitate new collaborations, demonstrate inclusive programming and support for under-represented groups, that aim to train young talent and have a mentorship component with the capability of long-range impact tracking.</p>
        </div>
        <div data-controller="guidelines">
          <h4 id="proposal_format"> <a href="guidelines#proposal_format" data-action="mouseup->guidelines#copy" value="proposal_format"><i class="align-middle me-2 fas fa-fw fa-link" value="/guidelines#proposal_format" ></i></a>4. Proposal format</h4>
        </div>
        <div class="ms-5">
          <p>The sections “A Short Overview” and “A Statement of Objectives” of the online form should total between 2 to 4 pages for workshops and FRGs. For other smaller or shorter programs we require less, preferably between 1 and 2 pages.</p>
          <p>The text that you submit should be plain text, with UTF-8 encoding (for the Unicode character set). Proposals will be compiled into a book using LaTeX2e, for the proposal review process.</p>
          <p>You may use LaTeX2e syntax for mathematical expressions or formatting. Formatting may include itemized lists, sections (\section*{section name}), subsections (\subsection*{subsection name}), citations, and bibliographies (add “\begin {thebibliography}{99} ...” to the end of the “Objectives” field). If you use custom macros, please send them to us, so that we can add them to our document’s preamble.</p>
        </div>
        <div data-controller="guidelines">
          <h4 id="confirmation"> <a href="guidelines#confirmation" data-action="mouseup->guidelines#copy" value="confirmation"><i class="align-middle me-2 fas fa-fw fa-link" value="/guidelines#confirmation" ></i></a>5. Confirmation</h4>
        </div>
        <div class="ms-5">
          <p>After you submit your proposal, you will receive an automatically-generated message containing the text of your proposal. The BIRS Program Coordinator will send you an e-mail message within one week to confirm that the proposal has been received and is complete. Please <a href="mailto:birs@birs.ca">contact us</a> if you do not receive confirmation or if the copy you receive back from us seems to be corrupted. If you have other questions about submissions of proposals, please feel free to contact us through the <a href="mailto:birs@birs.ca">BIRS Program Coordinator</a></p>
        </div>
      </div>
      <h4>EDI Rubric</h4>
      <div data-controller="guidelines">
        <h4 id="edi_rubric"> <a href="guidelines#edi_rubric" data-action="mouseup->guidelines#copy" value="edi_rubric"><i class="align-middle me-2 fas fa-fw fa-link" value="/guidelines#edi_rubric" ></i></a> EDI Rubric</h4>
      </div>
      <div class="card" style="overflow-x: auto">
        <div>
          <table class="table-responsive table-bordered">
            <thead>
              <tr>
                <th scope="col">PROPOSAL TITLE</th>
                <th scope="col">Average score</th>
                <th scope="col">Exceptional</th>
                <th scope="col">Good</th>
                <th scope="col">Neutral</th>
                <th scope="col">Requires action</th>
                <th scope="col">Not passing the bar</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <th class="table-padding">Organizing committee</th>
                <td class="d-none d-md-table-cell table-padding"></td>
                <td class="d-none d-md-table-cell table-padding">The organizing committee has been carefully chosen to represent diversity withn multiple categories, such as: career stage, backgrounds/minor tized groups, geography, subject area</td>
                <td class="d-none d-md-table-cell table-padding">Th organizers represent diversity withn thee distinct categories among: career stage, background/minoritiz ed groups, geography, subject area</td>
                <td class="d-none d-md-table-cell table-padding">Th organizers represent diversity withn two groups: career stage, background/minori tized groups, geography, subject area</td>
                <td class="d-none d-md-table-cell table-padding">Th members of the organizing committee have some variation within only one category: career stage, backgrounds/minori tized groups, geography, subject area</td>
                <td class="d-none d-md-table-cell table-padding">Th  organizers do not represent a diverse group in any sense.</td>
              </tr>
              <tr>
                <th scope="row" class="table-padding">Participants</th>
                <td class="d-none d-md-table-cell table-padding"></td>
                <td class="d-none d-md-table-cell table-padding">Th participant list has been crafted with explicit attention to diversity and inclusion along multiple axes. Participants include different backgrounds and under-represented groups, career stages and geographical areas</td>
                <td class="d-none d-md-table-cell table-padding">Th participant list explicitly addresses diversity along three different axes but not all, among: backgrounds and under-represented groups, career stages and geographical areas</td>
                <td class="d-none d-md-table-cell table-padding">Th participant list explicitly addresses diversity along two different axes but not all, among: backgrounds and under-represented groups, career stages and geographical areas</td>
                <td class="d-none d-md-table-cell table-padding">The participant list only includes people with some variation within one of the following groups: backgrounds and under-represented groups, career stages and geographical areas</td>
                <td class="d-none d-md-table-cell table-padding">The participant list is monolithic</td>
              </tr>
              <tr>
                <th scope="row" class="table-padding">Program</th>
                <td class="d-none d-md-table-cell table-padding"></td>
                <td class="d-none d-md-table-cell table-padding">The program is highly innovative and inclusive with a wide variety of strategiesto welcome and engagepeople from many different groups and career stages. Explicit measrementsof impact have been integrated into the proposal. </td>
                <td class="d-none d-md-table-cell table-padding">The program makes a conscious attempt to be iinclusive withseveral different types of programming.There is intent to track impact.</td>
                <td class="d-none d-md-table-cell table-padding">The program has some interesting aspects but requires more detailed planning and description.Unclear if impact can or will be tracked.</td>
                <td class="d-none d-md-table-cell table-padding">The program is traditional and needs major improvement</td>
                <td class="d-none d-md-table-cell table-padding">The participants can watch a series of lectures online instead</td>
              </tr>
              <tr>
                <th scope="row" class="table-padding">Recommendation</th>
                <th colspan="6"></th>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div data-controller="guidelines">
        <h4 id="scientific_merit_rubric"> <a href="guidelines#scientific_merit_rubric" data-action="mouseup->guidelines#copy" value="scientific_merit_rubric"><i class="align-middle me-2 fas fa-fw fa-link" value="/guidelines#scientific_merit_rubric" ></i></a> Scientific Merit Rubric</h4>
      </div>
      <div class="card" style="overflow-x: auto">
        <table class="table-responsive table-bordered">
          <thead >
            <tr>
              <th scope="col">PROPOSAL TITLE</th>
              <th scope="col">Average score</th>
              <th scope="col">(5) Exceptional</th>
              <th scope="col">(4) Good</th>
              <th scope="col">(3) Neutral</th>
              <th scope="col">(2) Requires action</th>
              <th scope="col">(1) Not passing the bar</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <th class="table-padding">Novelty <br><br>
                (Is this proposal unique?)
              </th>
              <td class="d-none d-md-table-cell table-padding"></td>
              <td class="d-none d-md-table-cell table-padding">The workshop shows a world-leading approach, a “first of its kind” endeavor. It is a forerunner in an emerging area of study that holds transformative potential.</td>
              <td class="d-none d-md-table-cell table-padding">The workshop is highly innovative in a developing field of study, significantly adding to current subject knowledge or application, and promoting new research directions.</td>
              <td class="d-none d-md-table-cell table-padding">The workshop outlines an interesting approach, idea or methodology that builds on a well- established area of study, with potential to advance subject knowledge.</td>
              <td class="d-none d-md-table-cell table-padding">Workshop topic is well established, but there is some indication of a fresh perspective or approach. Insufficient evidence provided as to how it will add to the established body of knowledge.</td>
              <td class="d-none d-md-table-cell table-padding">Subject is already well established, and there is little to no evidence that the proposal adds significantly to the existing knowledge. Similar workshops have been held previously/recently.</td>
            </tr>
            <tr>
              <th scope="row" class="table-padding">Scientific Impact <br><br>(Does this radically challenge our current understanding?)</th>
              <td class="d-none d-md-table-cell table-padding"></td>
              <td class="d-none d-md-table-cell table-padding">Impacts a large and diverse scientific community with significant scientific breakthroughs or real-world impact. <br><br> The impact is clearly defined and will be measured. <br><br>There is a high likelihood that this significant impact will be realized.</td>
              <td class="d-none d-md-table-cell table-padding">The outcomes of this workshop are likely to impact more than one field, with possible real- world impact.
              <br>Short-term benefits are notable, clearly described, and can be measured. <br><br> There is a reasonable likelihood that the impact will be realized.</td>
              <td class="d-none d-md-table-cell table-padding">Impact to a small area of research is described, but broader impact is unclear. <br><br> Short-term benefits to the research area are described and can be measured, but they are not exceptional. <br><br>Some of the objectives of the workshop could be achieved with the proposed activities.
              </td>
              <td class="d-none d-md-table-cell table-padding">The impact of the workshop is restricted to primarily one field or application. It might have minor real-world impact, but the case for this has not been clearly established. <br><br>Unclear how the impact can be measured. <br>Only a minority of the stated objectives of the workshop can be expected to be achieved.</td>
              <td class="d-none d-md-table-cell table-padding">No breakthrough. The outcome represents a “natural progression” in the field. Neglibible impact on field, application, or wider community. <br><br> There is lack of clarity or specificity about the benefits of the workshop activities.</td>
            </tr>
            <tr>
              <th scope="row" class="table-padding">Timeliness <br><br>(Is it important now?)</th>
              <td class="d-none d-md-table-cell table-padding"></td>
              <td class="d-none d-md-table-cell table-padding">Area has seen recent breakthroughs, time is ripe for new discoveries.</td>
              <td class="d-none d-md-table-cell table-padding">A hot topic area that is the focus of much current study.</td>
              <td class="d-none d-md-table-cell table-padding">Area has been under study for a long time, but new perspectives are emerging. Workshop will be of interest to the broad area.</td>
              <td class="d-none d-md-table-cell table-padding">Fairly obscure topic within the subject area, attracting little interest beyond specialists. No new developments to make the workshop relevant.</td>
              <td class="d-none d-md-table-cell table-padding">Extremely specialized niche of research, even within its broader subject area.</td>
            </tr>
            <tr>
              <th scope="row" class="table-padding">Potential for cross- disciplinary synergy <br><br>(Does it breakdown sub-specialty silos?)</th>
              <td class="d-none d-md-table-cell table-padding"></td>
              <td class="d-none d-md-table-cell table-padding">The interdisciplinary approach is reflected in the workshop team. The proposal is designed from an interdisciplinary perspective, with the aim to develop the interfacing frontiers. <br><br> The various disciplinary approaches and perspectives are fully integrated; the project is not an amalgamation of disciplinary-specific approaches.</td>
              <td class="d-none d-md-table-cell table-padding">The interdisciplinary approach is somewhat reflected in the team.
              The proposal incorporates different disciplinary approaches, bringing a novel perspective. <br><br>Proposes the application or adaptation of tools/methods/techniques from one discipline to solve a problem in another discipline.</td>
              <td class="d-none d-md-table-cell table-padding">The interdisciplinary nature of the project is achieved through an amalgamation of projects/activities that are disciplinary. <br><br>The proposal appears to have an interdisciplinary component “added on” to a more conventional project or program of research.</td>
              <td class="d-none d-md-table-cell table-padding">The team does not reflect the expertise required to execute an interdisciplinary approach. <br><br>The proposed tools/methods/techniques are already in use in or can be easily applied to the second disciplinary area, requiring little adaptation or development.</td>
              <td class="d-none d-md-table-cell table-padding">Subject area is hyper- focused, with little relevance to those outside of this specialization. <br><br>The application did not adequately establish the interdisciplinary nature of the project.</td>
            </tr>
            <tr>
              <th scope="row" class="table-padding">Training and mentorship <br><br>(Does it build future experts?)</th>
              <td class="d-none d-md-table-cell table-padding"></td>
              <td class="d-none d-md-table-cell table-padding">Clearly defined and integrated T&M goals and activities targeting a diverse population. Will have with long reaching impacts beyond the workshop.</td>
              <td class="d-none d-md-table-cell table-padding">Clearly defined T&M goals and activities, although further improvements could reasonably be made.</td>
              <td class="d-none d-md-table-cell table-padding">Some incorporation of T&M, but they are limited in detail, scope and/or long-term impact.</td>
              <td class="d-none d-md-table-cell table-padding">Invite list or program holds the potential for T&M opportunities, but this has not been explicitly integrated into the proposal or invite list.</td>
              <td class="d-none d-md-table-cell table-padding">Program or invitation list have been made with no consideration for T&M opportunities.</td>
            </tr>
            <tr>
              <th scope="row" class="table-padding">Participant/organizers lists <br><br>(Are the right people attending the workshop?)</th>
              <td class="d-none d-md-table-cell table-padding"></td>
              <td class="d-none d-md-table-cell table-padding">Experts from diverse research areas have expressed interest in attending and contributing. <br><br>
              Very strong organizational record. Organizers have used detailed well-defined criteria for selecting workshop participants.
              </td>
              <td class="d-none d-md-table-cell table-padding">Most of the subject experts are likely to participate. <br><br>Strong organizational record. Some effort has been made at explaining the mechanism for participant selection.</td>
              <td class="d-none d-md-table-cell table-padding">Some of the main experts in the workshop topic are present, but not necessarily any from the broader field or other areas that might be relevant for the workshop. <br><br>Criteria for selection unclear.</td>
              <td class="d-none d-md-table-cell table-padding">Several experts in the field are conspicuous by their absence. As a result, the workshop might be missing significant perspectives on the topic.</td>
              <td class="d-none d-md-table-cell table-padding">Few experts in the field are participating. Unclear if the organizers can achieve the workshop objectives with the proposed participants.</td>
            </tr>
            <tr>
              <th scope="row" class="table-padding">Recommendation</th>
              <th colspan="6"></th>
            </tr>
          </tbody>
        </table>
      </div>'

    guide = SiteSetting.create(guideline: guideline)
  end
end
