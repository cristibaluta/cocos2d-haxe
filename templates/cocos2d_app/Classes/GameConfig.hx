
class GameConfig
{
	//
	// Supported Autorotations:
	//		None,
	//		UIViewController,
	//		CCDirector
	//
	inline public static var kGameAutorotationNone = 0;
	inline public static var kGameAutorotationCCDirector = 1;
	inline public static var kGameAutorotationUIViewController = 2;

	//
	// Define here the type of autorotation that you want for your game
	//
	inline public static var GAME_AUTOROTATION = kGameAutorotationUIViewController;
}
