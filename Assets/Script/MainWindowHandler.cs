using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class MainWindowHandler : MonoBehaviour, IWindow
{
    
    public TMP_InputField NameText, ArmorText, HealthText, SpeedText, InitText, HitDiceText, PassPercepText, ProfiModifText;

    public TMP_InputField[] StatsSDCIWCText;

    public GameObject ItemPrefab;
    public Transform ItemsParent;

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

    public void HomeBtn()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }

    private void Start()
    {
        MainController.Instance.OnDataFetch += FetchDataHandler;
        CharRef = MainController.Instance.CurCharacter;

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

        // If you need to populate items
        if (CharRef.Items != null && ItemPrefab != null && ItemsParent != null)
        {
            foreach (string item in CharRef.Items)
            {
                GameObject newItem = Instantiate(ItemPrefab, ItemsParent);
                TMP_Text itemText = newItem.GetComponentInChildren<TMP_Text>();
                if (itemText != null)
                {
                    itemText.text = item;
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
public interface IWindow
{
    void OnDisableHandler();
    void FetchDataHandler();

    void FooterBTN(int index);
}
