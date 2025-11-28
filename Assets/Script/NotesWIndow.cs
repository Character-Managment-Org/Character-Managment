using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class NotesWIndow : MonoBehaviour, IWindow
{
    public Character CharRef;

    public GameObject NotesPrefab;
    public Transform NotesParent;
    private void Start()
    {
        MainController.Instance.OnDataFetch += FetchDataHandler;
        CharRef = MainController.Instance.CurCharacter;
        InstantiateNotes();
    }

    private void InstantiateNotes()
    {
        for (int i = 0; i < CharRef.Notes.Count; i++)
        {
            GameObject g = Instantiate(NotesPrefab, NotesParent).gameObject;
            g.transform.GetChild(0).GetComponent<TMP_InputField>().text = CharRef.Notes[i].ToString();
        }
    }

    public void AddItem()
    {
        GameObject g = Instantiate(NotesPrefab, NotesParent).gameObject;
        g.transform.GetChild(0).GetComponent<TMP_InputField>().text = "";
    }

    public void FetchDataHandler()
    {
        CharRef.Notes.Clear();

        for (int i = 1; i < NotesParent.childCount; i++)
        {
            CharRef.Notes.Add(NotesParent.GetChild(i).transform.GetChild(0).GetComponent<TMP_InputField>().text);
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
