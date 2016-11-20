PROJECT_NAME = "MXPhysics"

Pod::Spec.new do |s|
  s.name                        = PROJECT_NAME
  s.version                     = "1.0.0"
  s.summary                     = "#{PROJECT_NAME} is an Objective-C wrapper around Box2D."
  s.homepage                    = "https://github.com/cliftonr/#{PROJECT_NAME}.git"
  s.license                     = "MIT"
  s.author                      = { "Clifton Roberts" => "clifton.roberts@me.com" }
  s.ios.deployment_target       = "8.0"
  s.source                      = { :git => "https://github.com/cliftonr/#{PROJECT_NAME}.git", 
                                    :tag => s.version.to_s }
  s.requires_arc                = true
  s.module_name                 = PROJECT_NAME

  s.subspec 'Box2D' do |box2d|
    box2d.source_files          = 'Box2D/**/*.{h,cpp}'
    box2d.private_header_files  = 'Box2D/**/*.{h}'
  end

  s.subspec 'Core' do |cs|
    cs.dependency "#{PROJECT_NAME}/Box2D"
    cs.pod_target_xcconfig      = { 'HEADER_SEARCH_PATHS' => "$(PODS_ROOT)/#{PROJECT_NAME}" }
    cs.source_files             = 'Sources/**/*.{h,m,mm}'
    cs.public_header_files      = 'Sources/Public/**/*.h'
    cs.private_header_files     = 'Sources/Internal/**/*.h'
    cs.frameworks               = "QuartzCore"
  end
end
