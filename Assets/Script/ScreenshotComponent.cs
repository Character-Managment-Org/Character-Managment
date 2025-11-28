using System.Collections;
using UnityEngine;

public class ScreenshotComponent : MonoBehaviour
{
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            StartCoroutine(TakeScreenShotCoroutine());
        }
    }
    IEnumerator TakeScreenShotCoroutine()
    {
        yield return new WaitForEndOfFrame();
        TakeScreenShot();
    }
    [ContextMenu("TakeScreenShotFromEditor")]
    public void TakeScreenShotFromEditor()
    {
        TakeScreenShot();
    }

    private void TakeScreenShot()
    {
        string currentTime = System.DateTime.Now.ToString("MM-dd-yy (HH-mm-ss)");
        ScreenCapture.CaptureScreenshot("screenshot " + currentTime + ".png");
        Debug.Log("A screenshot was taken!");
    }
}
