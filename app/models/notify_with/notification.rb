class NotifyWith::Notification < ActiveRecord::Base
  self.table_name = 'notifications'

  belongs_to :receiver, polymorphic: true
  belongs_to :attached_object, polymorphic: true

  validates_presence_of :receiver_id,
                        :receiver_type,
                        :attached_object_id,
                        :attached_object_type,
                        :notification_type_id

  def send_notification(type: nil, attached_object: nil)
    self.notification_type_id = NotifyWith::NotificationType.find_by_name(type)
    self.attached_object = attached_object
    self
  end

  def to(receiver)
    self.receiver = receiver
    self
  end

  def notification_type
    NotifyWith::NotificationType.find(notification_type_id)
  end

  def mark_as_read
    update_columns(is_read: true)
  end

  def mark_as_send
    update_columns(is_send: true)
  end

  def deliver_now
    NotifyWith.mailer.send_mail_by(self).deliver_now if save
  end

  def deliver_later
    NotifyWith.mailer.send_mail_by(self).deliver_later if save
  end
end
