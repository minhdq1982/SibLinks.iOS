# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

# Comment this line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

def import_pods
    # Network Layer
    # Elegant HTTP Networking in Swift
	pod 'Alamofire', '~> 3.4'
    # A lightweight and pure Swift implemented library for downloading and cacheing image from the web.
	pod 'Kingfisher', '~> 2.6'
    # SwiftyJSON makes it easy to deal with JSON data in Swift
	pod 'SwiftyJSON', '~> 2.3'
    # Network abstraction layer written in Swift
	pod 'Moya', '7.0.4'
    pod 'Result', '~> 2.0'
    # Facebook SDK
    # Official Facebook SDK for iOS to access Facebook Platform's core features
    pod 'FBSDKCoreKit', '~> 4.15'
    # Official Facebook SDK for iOS to access Facebook Platform with features like Login, Share and Message Dialog, App Links, and Graph API
    pod 'FBSDKLoginKit', '~> 4.15'
    # Official Facebook SDK for iOS to access Facebook Platform's Sharing Features
    pod 'FBSDKShareKit', '~> 4.15'
    # UI
    # The little alert that could
    pod 'SDCAlertView', '5.1.1'
    # Declarative Auto Layout in Swift
    pod 'Cartography', '~> 0.6'
    # HEX color handling as an extension for UIColor. Written in Swift.
    pod 'SwiftHEXColors', '1.0'
    # Design and prototype UI, interaction, navigation, transition and animation for App Store ready Apps in Interface Builder with IBAnimatable.
    # Xcode 8.0, swift 2.3 using 2.8
    pod 'IBAnimatable', '2.7'
    # Xcode 7.3.1, swift 2.3 using 2.7
    # pod 'IBAnimatable', '2.7'
    # Star rating
    pod 'Cosmos', '~> 1.2'
    # A paging view with customizable menu
    pod 'PagingMenuController', '1.2.0'
    # A generic, easy to use stretchy header view for UITableView and UICollectionView
    pod 'GSKStretchyHeaderView', '0.12.2'
    # A Splash view that animates and reveals its content, inspired by the Twitter splash.
    pod 'RevealingSplashView', '0.0.7'
    # An easy to use UITableViewCell subclass that allows to display swipeable buttons with a variety of transitions
    pod 'MGSwipeTableCell', '~> 1.5'
    # Simple PhotoBrowser/Viewer inspired by facebook, twitter photo browsers written by swift2.0.
    pod 'SKPhotoBrowser', '3.1.0'
    # Login with Google Plus
    pod 'Google/SignIn'
    # In-app event tracking
    pod 'Google/Analytics'
    # A debug log module for use in Swift projects.
    pod 'XCGLogger', '3.6.0'
    # Firebase: used to push notification.
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    # Crashlytics
    pod 'Fabric'
    pod 'Crashlytics'
    # Whisper is a component that will make the task of display messages and in-app notifications simple.
    pod 'Whisper', '3.1.1'
    # Give pull-to-refresh & infinite scrolling to any UIScrollView
    pod 'SVPullToRefresh', '~> 0.4.1'
end

target 'SibLinks' do

	# Pods for SibLinks
	import_pods

end

target 'SibLinks Sandbox' do

    # Pods for SibLinks
    import_pods

end

post_install do |installer|

    file_names = [
        './Pods/Target Support Files/Pods-SibLinks Sandbox/Pods-SibLinks Sandbox.debug.xcconfig',
        './Pods/Target Support Files/Pods-SibLinks Sandbox/Pods-SibLinks Sandbox.release.xcconfig'
    ]

    # append pre-processor definitions

    file_names.each do |file_name|
        text = File.read(file_name)
        File.open(file_name, 'w') { |f|
            f.puts text.gsub(/OTHER_SWIFT_FLAGS/, "OTHER_SWIFT_FLAGS_SHARED")
        }

        File.open(file_name, 'a') { |f|
            f.puts "OTHER_SWIFT_FLAGS = $(OTHER_SWIFT_FLAGS_SHARED) \"-D\" \"SANDBOX_VERSION\""
        }
    end

		installer.pods_project.targets.each do |target|
        target.build_configurations.each do |configuration|
            configuration.build_settings['SWIFT_VERSION'] = "2.3"
        end

        if target.name == 'IBAnimatable'
            target.build_configurations.each do |config|
                config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '/Applications/Xcode.app/Contents/Developer/Toolchains/Swift_2.3.xctoolchain/usr/lib/swift/iphonesimulator']
            end
        end

        if target.name == 'Cosmos'
            target.build_configurations.each do |config|
                config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '/Applications/Xcode.app/Contents/Developer/Toolchains/Swift_2.3.xctoolchain/usr/lib/swift/iphonesimulator']
            end
        end
    end
end
