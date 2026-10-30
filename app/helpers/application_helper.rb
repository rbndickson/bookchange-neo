module ApplicationHelper
  def form_control_class(record, attribute)
    record.errors[attribute].any? ? 'form-control is-invalid' : 'form-control'
  end
end
