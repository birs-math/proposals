module SchedulesHelper
  def schedule_proposal(proposal_code)
    return '' if proposal_code.blank?

    return '(excluded date)' if proposal_code.match?('w66') # placeholder code

    proposal = Proposal.find(proposal_code)
    if proposal.present?
      "[#{link_to proposal.code, submitted_proposal_path(proposal),
                  target: :blank}] #{proposal.title}"
    else
      ''
    end
  end

  def choice_assignment(choices, choose)
    return '' if choices.blank?

    assign = 0
    choices.map { |choice| choice == choose ? assign += 1 : next }
    assign
  end

  def proposal_manual_assignments(codes)
    proposal_codes = codes - [""]
    count = 0
    proposal_codes.each do |code|
      proposal = Proposal.find(code)
      proposal.present? && proposal.assigned_date.present? ? count += 1 : next
    end
    count
  end

  def schedule_run_time(run)
    return '' if run.start_time.blank?

    return (link_to 'Abort the run', abort_run_schedules_path(run_id: run.id), method: :post) if run.end_time.blank?

    Time.at(run.end_time - run.start_time).utc.strftime("%H:%M:%S")
  end

  def proposals_count(schedules)
    count = 0
    schedules.each do |schedule|
      code = schedule.proposal
      count += 1 if code.match?(' and ')
      count += 1 unless code.blank? || code.match?('w66') # placeholder code
    end
    count
  end

  def link_to_results(run)
    return '(no results yet)' if run.schedules.blank?

    link_to 'View results', optimized_schedule_schedules_url(run_id: run.id)
  end

  def delete_shedule_run(run)
    link_to 'Delete', destroy_schedule_runs_url(run), method: :delete,
                                                      data: { confirm: "Are you sure to delete this record?" }
  end

  def link_to_schedule_result(run, id)
    return id if run.schedules.blank?

    link_to id, optimized_schedule_schedules_url(run_id: run.id)
  end

  def program_years
    years = []
    (0..7).each do |i|
      years.append([Date.current.year + i, Date.current.year + i])
    end
    return years
  end
end
