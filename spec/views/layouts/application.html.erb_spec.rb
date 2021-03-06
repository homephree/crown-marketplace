require 'rails_helper'

RSpec.describe 'layouts/application.html.erb' do
  describe 'feedback links' do
    let(:mail_to_link_selector) do
      %(a[href="mailto:#{feedback_email_address}"])
    end

    before do
      allow(Marketplace).to receive(:feedback_email_address)
        .and_return(feedback_email_address)
    end

    context 'when feedback email address is present' do
      let(:feedback_email_address) { 'feedback@example.com' }

      it 'displays link to feedback email address in beta banner' do
        render

        expect(rendered).to have_css(".govuk-phase-banner #{mail_to_link_selector}")
      end

      it 'displays link to feedback email address above footer' do
        render

        expect(rendered).to have_css(".footer-feedback #{mail_to_link_selector}")
      end
    end

    context 'when feedback email address is not present' do
      let(:feedback_email_address) { nil }

      it 'does not display link to feedback email address in beta banner' do
        render

        expect(rendered).not_to have_css(".govuk-phase-banner #{mail_to_link_selector}")
      end

      it 'does not display link to feedback email address in footer' do
        render

        expect(rendered).not_to have_css(".govuk-footer #{mail_to_link_selector}")
      end
    end
  end

  it 'renders the page title stored in the locale file' do
    render
    expected = t('layouts.application.title')
    expect(rendered).to have_css('title', text: expected, visible: false)
  end

  it 'adds an optional prefix to the page title' do
    view.content_for(:page_title_prefix) { 'Prefix' }
    render
    expected = 'Prefix: ' + t('layouts.application.title')
    expect(rendered).to have_css('title', text: expected, visible: false)
  end
end
