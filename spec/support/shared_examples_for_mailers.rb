shared_examples 'common mailer template elements' do
  it 'has MoJ banner image' do
    html = get_message_part(mail, 'html')
    expect(html).to match(/.*\/gov.uk_logo_crown_invert_trans-64x64-[\w]+\.png/)
  end
end
