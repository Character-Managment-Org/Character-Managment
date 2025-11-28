using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class StartSetupWindowHandler : MonoBehaviour
{
    public GameObject NewCharacterGO;


    public TMP_InputField NameText, ArmorText, HealthText, SpeedText, InitText, HitDiceText, PassPercepText, ProfiModifText;

    public TMP_InputField[] StatsSDCIWCText;

    public Character CharRef;

    public void FetchDataHandler()
    {
        //Debug.Log("Armor fetch " + ArmorText.text);
        CharRef.CharName = NameText.text;
        CharRef.ArmorClass = ArmorText.text;
        CharRef.Health = HealthText.text;
        CharRef.Speed = SpeedText.text;
        CharRef.Initiative = InitText.text;
        CharRef.HitDice = HitDiceText.text;
        CharRef.PassivePerception = PassPercepText.text;
        CharRef.Proficiency = ProfiModifText.text;

        CharRef.StatsSDCIWC = new string[]
        {
            StatsSDCIWCText[0].text,
            StatsSDCIWCText[1].text,
            StatsSDCIWCText[2].text,
            StatsSDCIWCText[3].text,
            StatsSDCIWCText[4].text,
            StatsSDCIWCText[5].text

        };
    }
    public int CurCharIndex;

    private void Start()
    {
        CharRef = MainController.Instance.CurCharacterList[CurCharIndex];
        UpdateUi();
    }

    public void NewCharBtn()
    {
        Character ch = MainController.Instance.EmptyCharacter;
        MainController.Instance.CurCharacterList.Insert(0, ch);
        MainController.Instance.CurCharacter = ch;
        MainController.Instance.FooterBtn(0);
        Destroy(this.gameObject);
    }

    public void ConfirmCharBtn()
    {
        MainController.Instance.CurCharacter = CharRef;
        MainController.Instance.FooterBtn(0);
        Destroy(this.gameObject);

    }

    public void NextCharBtn(int index)
    {
        if (MainController.Instance.CurCharacterList.Count == 0)
        {
            Debug.LogWarning("Character list is empty");
            return;
        }
        if (index == 0)
        {
            // Index 0 means -1 (previous character)
            CurCharIndex--;

            // Wrap around to the end if we go below 0
            if (CurCharIndex < 0)
            {
                CurCharIndex = MainController.Instance.CurCharacterList.Count - 1;
                Debug.Log("// Wrap around to the end if we go below 0");
            }
        }
        else
        {
            // Any other index means +1 (next character)
            CurCharIndex++;

            // Wrap around to the beginning if we exceed the list length
            if (CurCharIndex >= MainController.Instance.CurCharacterList.Count)
            {
                CurCharIndex = 0;
                Debug.Log("// Wrap around to the beginning if we exceed the list length");
            }
        }
        Debug.Log(CurCharIndex);
        CharRef = MainController.Instance.CurCharacterList[CurCharIndex];
        UpdateUi();
    }

    private void UpdateUi ()
    {
        //MainController.Instance.OnDataFetch += FetchDataHandler;
        //CharRef = MainController.Instance.CurCharacter;

        //Debug.Log(CharRef.ArmorClass);
        NameText.text = CharRef.CharName;
        ArmorText.text = CharRef.ArmorClass;

        HealthText.text = CharRef.Health;
        SpeedText.text = CharRef.Speed;
        InitText.text = CharRef.Initiative;
        if (CharRef.Initiative != "0")
        {

        }

        HitDiceText.text = CharRef.HitDice;
        PassPercepText.text = CharRef.PassivePerception;
        ProfiModifText.text = CharRef.Proficiency;

        // Assign stats (Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma)
        if (CharRef.StatsSDCIWC != null && StatsSDCIWCText.Length >= 6)
        {
            for (int i = 0; i < 6; i++)
            {
                StatsSDCIWCText[i].text = CharRef.StatsSDCIWC[i].ToString();
            }
        }


    }

    private void OnDisable()
    {
        //MainController.Instance.OnDataFetch -= FetchDataHandler;
        //OnDisableHandler();
    }

    public void OnDisableHandler()
    {
        //FetchDataHandler();
        //Destroy(this.gameObject);
    }

    public void FooterBTN(int index)
    {
        MainController.Instance.FooterBtn(index);
    }
}
