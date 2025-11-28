using System.Collections;
using System.Collections.Generic;
//using Unity.VisualScripting;
using UnityEngine;
//using UnityEngine.Rendering;
using TMPro;

public class ItemsWindowHandler : MonoBehaviour, IWindow
{

    public Character CharRef;

    public GameObject ItemPrefab;
    public Transform ItemsParent;
    private void Start()
    {
        MainController.Instance.OnDataFetch += FetchDataHandler;
        CharRef = MainController.Instance.CurCharacter;
        InstantiateItems();
    }

    private void InstantiateItems()
    {
        for (int i = 0; i < CharRef.Items.Count; i++)
        {
            GameObject g = Instantiate(ItemPrefab, ItemsParent).gameObject;
            g.transform.GetChild(0).GetComponent<TMP_InputField>().text = CharRef.Items[i].ToString();
        }
    }

    public void AddItem()
    {
        GameObject g = Instantiate(ItemPrefab, ItemsParent).gameObject;
        g.transform.GetChild(0).GetComponent<TMP_InputField>().text = "Item";
    }

    public void FetchDataHandler()
    {
        CharRef.Items.Clear();

        for (int i = 1; i < ItemsParent.childCount; i++)
        {
            Transform childTransform = ItemsParent.GetChild(i);
            if (childTransform != null && childTransform.childCount > 0)
            {
                Transform firstChild = childTransform.GetChild(0);
                if (firstChild != null)
                {
                    TMP_InputField inputField = firstChild.GetComponent<TMP_InputField>();
                    if (inputField != null)
                    {
                        CharRef.Items.Add(inputField.text);
                    }
                    else
                    {
                        Debug.LogWarning($"TMP_InputField component not found on child object at index {i}");
                    }
                }
            }
        }
    }

    private void OnDisable()
    {
        MainController.Instance.OnDataFetch -= FetchDataHandler;
        OnDisableHandler();
    }

    public void OnDisableHandler()
    {
        FetchDataHandler();
        Destroy(this.gameObject);
    }

    public void FooterBTN(int index)
    {
        MainController.Instance.FooterBtn(index);
    }
}
