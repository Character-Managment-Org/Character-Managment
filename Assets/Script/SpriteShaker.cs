using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using TMPro;

public class SpriteShaker : MonoBehaviour
{
    [SerializeField] private float shakeDuration = 2f; 
    [SerializeField] private float shakeIntensity = 0.1f;
    [SerializeField] private float numberSwapInterval = 0.1f;

    [SerializeField] private TMP_Text numberText;
    [SerializeField] private int minNumber = 1; 
    [SerializeField] private int maxNumber = 20; 

    private Vector3 originalPosition;
    private Coroutine shakeCoroutine;
    private int targetNumber; // The final number to display after shaking

    private void Awake()
    {
        originalPosition = transform.localPosition;
    }

    public void StartShakeAnimation(int newNumber)
    {
        if (shakeCoroutine != null)
        {
            StopCoroutine(shakeCoroutine);
        }

        transform.localPosition = originalPosition;

        targetNumber = UnityEngine.Random.Range(0, 20);

        shakeCoroutine = StartCoroutine(ShakeAndSwapRoutine());
    }

    private IEnumerator ShakeAndSwapRoutine()
    {
        float elapsedTime = 0f;
        float nextNumberSwapTime = 0f;

        while (elapsedTime < shakeDuration)
        {
            elapsedTime += Time.deltaTime;

            float progress = elapsedTime / shakeDuration;

            float currentIntensity = shakeIntensity * (1f - progress);

            Vector3 randomOffset = Random.insideUnitCircle * currentIntensity;
            transform.localPosition = originalPosition + randomOffset;

            
            if (Time.time >= nextNumberSwapTime)
            {
                if (progress < 0.9f)
                {
                    numberText.text = Random.Range(minNumber, maxNumber + 1).ToString();
                }
                else
                {
                    numberText.text = targetNumber.ToString();
                }

                nextNumberSwapTime = Time.time + numberSwapInterval;
            }

            yield return null;
        }

        transform.localPosition = originalPosition;
        numberText.text = targetNumber.ToString();

        shakeCoroutine = null;
    }

    public void StopShakeEarly()
    {
        if (shakeCoroutine != null)
        {
            StopCoroutine(shakeCoroutine);
            transform.localPosition = originalPosition;
            numberText.text = targetNumber.ToString();
            shakeCoroutine = null;
        }
    }
}