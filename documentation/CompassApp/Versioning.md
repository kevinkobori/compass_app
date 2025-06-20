- [x] 0.1.0; feat: add Google Compass App project following new official Flutter app architecture.
	- Based on: https://docs.flutter.dev/app-architecture
- [x] 0.1.1; docs: move Obsidian notes to dedicated 'CompassApp' folder
- [x] 0.1.2; refactor(localization): migrate localization logic from Map-based to strongly-typed language classes
	- Replace translation maps with language-specific classes implementing the AppStrings interface.
	- Update AppLocalization to delegate lookups to typed classes.
	- Delegate and public interface remain compatible.
	- Improves IDE autocomplete, reduces typos, and eases refactoring.
	- Note: Suitable for small projects. For large-scale or production apps, prefer the .arb standard and codegen.
- [x] 0.1.3; test(integration): internationalization of local and server integration tests
	- Parameterizes integration tests to run automatically for both supported locales (en_US and pt_BR).
	- Updates all text matching and interactions to use strongly-typed AppStrings, ensuring multi-language compatibility.
	- Ensures full coverage of critical flows regardless of the active locale.
	- Fixes use of the 'Save' button label to be dynamic based on the current language.
	- Improves test robustness and prevents i18n-related regressions.

	Related files:
	- integration_test/app_local_data_test.dart
	- integration_test/app_server_data_test.dart
