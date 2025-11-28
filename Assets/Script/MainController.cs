using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;
using UnityEngine.SceneManagement;
//using UnityEngine.TextCore.Text;

public class MainController : MonoBehaviour
{
    public static MainController Instance;

    public Character CurCharacter;
    public Character EmptyCharacter;
    public event Action OnDataFetch;
    public List<Character> PregeneratedCharacters;
    public List<Character> CurCharacterList;

    private void Awake()
    {
        //Debug.Log("Awake");
        Screen.orientation = ScreenOrientation.Portrait;
        Instance = this;
        Load();
        //if(CurCharacter == null)
        //{
            //Debug.Log("CurCharacter == null");
            //CurCharacter = new Character();
        //}

       // Debug.Log(CurCharacter.ArmorClass);
        StartCoroutine(SavingCor());
    }

    private void Start()
    {


    }

    public IEnumerator SavingCor()
    {
        while(true)
        {
            yield return new WaitForSeconds(10f);
            Save();
        }
    }

    private void FetchUICharacterDataAndAssignToCurCharacter()
    {
        OnDataFetch?.Invoke();
    }

    public void Save()
    {
        FetchUICharacterDataAndAssignToCurCharacter();
        BinaryFormatter bf = new BinaryFormatter();
        FileStream file = File.Create(Application.persistentDataPath + "/savedGame.zs");
#if UNITY_EDITOR
        //Debug.Log("Save " + Application.persistentDataPath + "/savedGame.zs");
#endif
        Data data = new Data();
        //data.Character = CurCharacter;
        data.ListOfCharacters = CurCharacterList;

        bf.Serialize(file, data);
        file.Close();
    }

    public void Load()
    {

        if (File.Exists(Application.persistentDataPath + "/savedGame.zs"))
        {
            BinaryFormatter bf = new BinaryFormatter();
            FileStream file = File.Open(Application.persistentDataPath + "/savedGame.zs", FileMode.Open);
#if UNITY_EDITOR
            Debug.Log("Load " + Application.persistentDataPath + "/savedGame.zs");
#endif

            Data data = (Data)bf.Deserialize(file);
            //CurCharacter = data.Character;
            if(data.ListOfCharacters == null)
            {
                Debug.LogWarning("EmptyList. Populating");
                CurCharacterList = new List<Character>();
                //CurCharacterList.Add(CurCharacter);

                for (int i = 0; i < PregeneratedCharacters.Count; i++)
                {
                    CurCharacterList.Add(PregeneratedCharacters[i]);
                }
                
            } else
            {
                Debug.Log("LoadingList");
                CurCharacterList = data.ListOfCharacters;
            }
                

            file.Close();
        }
        else
        {
#if UNITY_EDITOR
            Debug.Log("No Load Data");
#endif
            //_isNewGame = true;
            Debug.LogWarning("EmptyList. Populating");
            CurCharacterList = new List<Character>();
            //CurCharacterList.Add(CurCharacter);

            for (int i = 0; i < PregeneratedCharacters.Count; i++)
            {
                CurCharacterList.Add(PregeneratedCharacters[i]);
            }
        }
    }
    public GameObject[] WindowsPIDNHP;
    public Transform WindowsParent;
    public void FooterBtn(int index)
    {
        switch(index)
        {
            case 0:
                Debug.Log("Profile");
                Instantiate(WindowsPIDNHP[0], WindowsParent);
                break;
            case 1:
                Debug.Log("Items");
                Instantiate(WindowsPIDNHP[1], WindowsParent);
                break;
            case 2:
                Debug.Log("Dice");
                Instantiate(WindowsPIDNHP[2], WindowsParent);
                break;
            case 3:
                Debug.Log("Notes");
                Instantiate(WindowsPIDNHP[3], WindowsParent);
                break;
            case 4:
                Debug.Log("HallOfFame");
                Instantiate(WindowsPIDNHP[4], WindowsParent);
                break;
            case 5:
                Debug.Log("Profile");
                Instantiate(WindowsPIDNHP[5], WindowsParent);
                break;

            default:
                Debug.Log("default");
                Instantiate(WindowsPIDNHP[0], WindowsParent);
                break;
        }
    }

    public void HomeBtn()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }

    private void OnDisable()
    {
        Save();
    }

}

[System.Serializable]
public class Character
{
    //public Character()
    //{
    //    //Debug.Log("Character() contructor");
    //    //CharName = "Namee";
    //    //ArmorClass = "15"; Health = "20"; Speed = "30ft"; HitDice = "5d6"; Initiative = "+10";
    //    //StatsSDCIWC = new int[6] { 10, 10, 10, 10, 10, 10 };
    //}

    public string CharName;
    public string ArmorClass, Health, Speed, HitDice,Initiative,PassivePerception,Proficiency;
    public int SavesS, SavesF;
    public string[] StatsSDCIWC;
    public string[] Money;
    public List<string> Items;
    public List<string> Notes;

}

[System.Serializable]
public struct Data
{
    public List<Character> ListOfCharacters;
    public Character Character;
}
