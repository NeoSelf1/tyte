# Uncomment the next line to define a global platform for your project
# platform :ios, '17.5'

target 'tyte' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Google 관련 2개 라이브러리에서 다른 버전의 GTMSessionFetcher 사용하는 것 방지 위해, 사용 패키지 버전과 함께 명시
  pod 'GTMSessionFetcher', '~> 3.1.1'
  pod 'GoogleSignIn', '~> 7.0'
  pod 'GoogleSignInSwiftSupport', '~> 7.0'
  
  target 'widgetExtension' do
  end
  
  target 'tyteTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'tyteUITests' do
    # Pods for testing
  end

end
