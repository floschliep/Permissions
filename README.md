# Permissions.swift
`Permissions.swift` is an elegant API to read and request permissions on iOS. At the moment, the following permissions are supported:

- `camera`
- `notifications`

Feel free to submit issues or pull requests if you need other types of permissions.

## Example

```
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions…) -> Bool {
		let permissions = Permissions()
		permissions.notificationOptions = [.alert]
		
		let viewController = OnboardingViewController(permissions: permissions)
		…
	}
}

class OnboardingViewController: UIViewController {
	init(permissions: Permissions) { … }

	func didTapContinueButton() {
		if self.permissions[.notifications] == .unknown {
			self.permissions.request(for: .notifications) { status in
				… // callback is always on the main queue
			}
		} else {
			…
		}
	}
}
```

## Why?

`Permissions.swift` provides a simple, unified and testable wrapper around permissions. Its enum-based API makes your code **more readable** and by abstracting permissions into a separate class **more testable**.

When testing your app, you can simply inject a mock-`Permissions` object that doesn’t actually read/request iOS permissions, but instead behaves in a way that is suitable for your test.

```
class OnboardingTests: XCTestCase {
	func testPermissionDenied() {
		let permissions = MockPermissions()
		permissions.onRequest = { $0.status = .denied }

		let viewController = OnboardingViewController(permissions: permissions)
		…
	}
}

class MockPermissions: Permissions {
    var status = PermissionStatus.unknown
    var onRequest: ((MockPermissions) -> Void)?
    
    override func status(`for` type: PermissionType) -> PermissionStatus {
        return self.status
    }
    
    override func request(`for` type: PermissionType, completion: @escaping (PermissionStatus) -> Void) {
        self.onRequest?(self)
        completion(self.status)
    }
}
```

## Installation
It’s just a single `.swift` file. If you feel the need to use Carthage or Cocoapods, please submit a pull request.

## Who?
[@fabianehlert](https://twitter.com/fabianehlert) and I, [@floschliep](https://twitter.com/floschliep), created this while working on [Cheese](https://thecheeseapp.com).

## License
`Permissions.swift` is available under the MIT license. See the LICENSE file for more info.