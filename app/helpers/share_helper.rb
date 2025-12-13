# app/helpers/share_helper.rb
module ShareHelper
  # Generate the shareable URL for an event
  def share_url(event, base_url)
    "#{base_url}/performances/#{event.id}/details"
  end

  # Generate share text for an event
  def share_text(event)
    "Check out #{event.name} at #{event.venue} on #{event.date}! 🎭"
  end

  # URL-encoded share text
  def encoded_share_text(event)
    URI.encode_www_form_component(share_text(event))
  end

  # URL-encoded share URL
  def encoded_share_url(event, base_url)
    URI.encode_www_form_component(share_url(event, base_url))
  end

  # WhatsApp share URL
  def whatsapp_share_url(event, base_url)
    text = "#{share_text(event)} #{share_url(event, base_url)}"
    "https://wa.me/?text=#{URI.encode_www_form_component(text)}"
  end

  # iMessage / SMS share URL (works on iOS and Android)
  def sms_share_url(event, base_url)
    text = "#{share_text(event)} #{share_url(event, base_url)}"
    "sms:?&body=#{URI.encode_www_form_component(text)}"
  end

  # Facebook Messenger share URL
  def messenger_share_url(event, base_url)
    "https://www.facebook.com/dialog/send?link=#{encoded_share_url(event, base_url)}&app_id=291494419107518&redirect_uri=#{encoded_share_url(event, base_url)}"
  end

  # Telegram share URL
  def telegram_share_url(event, base_url)
    text = share_text(event)
    url = share_url(event, base_url)
    "https://t.me/share/url?url=#{URI.encode_www_form_component(url)}&text=#{URI.encode_www_form_component(text)}"
  end

  # Twitter/X share URL
  def twitter_share_url(event, base_url)
    text = share_text(event)
    url = share_url(event, base_url)
    "https://twitter.com/intent/tweet?text=#{URI.encode_www_form_component(text)}&url=#{URI.encode_www_form_component(url)}"
  end

  # Facebook share URL
  def facebook_share_url(event, base_url)
    "https://www.facebook.com/sharer/sharer.php?u=#{encoded_share_url(event, base_url)}"
  end

  # Email share URL
  def email_share_url(event, base_url)
    subject = "Check out this event: #{event.name}"
    body = "#{share_text(event)}\n\n#{share_url(event, base_url)}"
    "mailto:?subject=#{URI.encode_www_form_component(subject)}&body=#{URI.encode_www_form_component(body)}"
  end

  # Instagram share data (for JavaScript to use)
  def instagram_share_text(event, base_url)
    "🎭 #{event.name}\n📍 #{event.venue}\n📅 #{event.date}\n🕐 #{event.time}\n\n#{share_url(event, base_url)}"
  end
end
