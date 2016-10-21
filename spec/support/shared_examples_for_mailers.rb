shared_examples 'common mailer template elements' do
  it 'has MoJ banner image' do
    html = get_message_part(mail, 'html')
    expect(html).to match(/.*\/moj_logo_email\.png/)
  end
end
