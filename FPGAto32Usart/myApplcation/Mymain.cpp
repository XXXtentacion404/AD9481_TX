/**
*********************************************************************
*********
* @project_name :templateDevelopment
* @file : Mymain.cpp
* @author : zen3
* @brief : None
* @attention : None
* @date : 2023/4/27 
*********************************************************************
*********
*/
//
#include "Myapplication.h"
#include "IncludeALL.h"
#include "MySchedule.h"

void Mymain() {
    MyFFT myFft;
    uint8_t receiveAll[SIZEMAX];
    memset(receiveAll, 0, SIZEMAX);
    uint16_t arraycopy[SIZE];
    MyKey myKey;
    MyUsart myUsart(&huart1);
    HAL_Delay(20);
    HAL_StatusTypeDef sinal;
    sinal = HAL_UART_Receive_DMA(&huart3, receiveAll, SIZEMAX);
//
    for (;;) {

        myKey.KeyScan(20);
        if ((myKey.flage) && (sinal == HAL_OK)) {
            if (receiveAll == nullptr) {
                uint8_t *receiveAll = new uint8_t[SIZEMAX];
                memset(receiveAll, 0, SIZEMAX);
            }
            HAL_UART_DMAStop(&huart3);
         //   myUsart.Myprintf("hello\n");
//            memset(arraycopy,0,SIZE);
            Character_to_number(receiveAll, SIZEMAX, arraycopy);
            for (int i = 0; i < SIZE; ++i) {
                myUsart.Myprintf("%d\n", arraycopy[i]);
            }
            memset(receiveAll, 0, SIZEMAX);
            memset(arraycopy, 0, SIZE);
            // HAL_UART_Transmit(&huart1,(uint8_t *)arraycopy,2048,HAL_MAX_DELAY);
//            myFft.FFTInit(arraycopy);
//            myFft.FFTProcess();
//            myUsart.SendFloat(myFft.GetOutputbuf(),1024);
//            delete []receiveAll;
//            receiveAll= nullptr;

//            for (int i = 0; i < SIZEMAX; ++i) {
//                myUsart.Myprintf("receive:%d:\t%c\n",i,receive[i]);
//            }

            myKey.flage = 0;
            HAL_UART_Receive_DMA(&huart3, receiveAll, SIZEMAX);


        }

    }
}



//}
/***************************************************************
  *  @brief     ���ж��ļ����Ե���c++����
  *  @param     ����
  *  @note      ��ע ���˺�������it�ļ�����
  *  @Sample usage:     ������ʹ�÷��� ��ֱ�ӵ���
   * @author     wangzibo
 **************************************************************/

void ItUsart(DMA_HandleTypeDef * hdma_usartx_rx)
{
   //myUsart3.ReceiveDataCallBack(hdma_usartx_rx);

}

void Character_to_number(uint8_t *data,uint16_t Size,uint16_t* arraycopy) {

    char temp[7]="0";uint16_t k=0;uint16_t  m=0;

    for (  int i = 0; i <(Size) ; ++i) {
            if (data[i]>=48 && data[i] <=57) {
                    temp[k++] = data[i];

            }
            else if (data[i]=='\n'){
                memset(temp,0,7);
            }
            else if (data[i]=='\r'&&(i>0)){
                    arraycopy[m++] = atoi(temp);
                    k = 0;


            }
        if (m == SIZE) {
            break;
        }
        }


        }





