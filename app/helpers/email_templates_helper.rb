module EmailTemplatesHelper
  def types_of_email
    EmailTemplate.email_types.map do |k, _|
      first_word = k&.split('_')&.first&.capitalize
      [
        case first_word
        when 'Revision'
          arr = k.split("_")
          if arr.second == 'spc'
            "#{first_word} SPC"
          else
            first_word
          end
        when 'Decision'
          "#{first_word} Email"
        when 'Organizer', 'Participant'
          "#{first_word} Invitation"
        else
          k.humanize
        end, k
      ]
    end
  end

  def name_of_templates
    templates = EmailTemplate.all.map do |template|
      email_type = template.email_type.split('_').first.capitalize
      case email_type
      when 'Revision'
        arr = template.email_type.split('_')
        if arr[1] == 'spc'
          "#{email_type} SPC: #{template&.title}"
        else
          "#{email_type}: #{template&.title}"
        end
      when 'Decision'
        "#{email_type} Email: #{template&.title}"
      when 'Organizer' || 'Participant'
        next
      else
        "#{email_type}: #{template&.title}"
      end
    end

    templates.compact
  end

  def show_context
    text = ''
    InviteMailerContext.placeholders.each do |k, v|
      wrapped_key = "{{ #{k} }}"
      entry = v.present? ? "#{wrapped_key} - #{v}" : "#{wrapped_key}"
      text << "<span class=\"fw-bold\">#{entry}</span><br>"
    end

    text.html_safe
  end
end
