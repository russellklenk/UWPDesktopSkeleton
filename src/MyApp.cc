#include <Windows.h>
#include <wrl.h>

#include "MyApp.h"

using namespace Microsoft::WRL;

/* @summary Implement the entry point of the application.
 * @param args Command-line arguments passed to the application.
 * @return The application exit code, with zero representing success.
 */
[Platform::MTAThread]
int WINAPIV
main
(
	Platform::Array<Platform::String^>^ args
)
{
	return 0;
}

