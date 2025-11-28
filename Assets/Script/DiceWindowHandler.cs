using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DiceWindowHandler : MonoBehaviour, IWindow
{
    private void OnDisable()
    {

        OnDisableHandler();
    }

    public void OnDisableHandler()
    {

        Destroy(this.gameObject);
    }

    public void FooterBTN(int index)
    {
        MainController.Instance.FooterBtn(index);
    }

    public void FetchDataHandler()
    {
        
    }
}
