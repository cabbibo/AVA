using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System.IO;
using System.Runtime.Serialization.Formatters.Binary;



   [Serializable]
    public class AvatarData {
      public float id;
       public int themeID; // which theme we are saving;
      public int animationID;  // which animation we are using

      public AvatarData(float idIn, int themeNameIn , int animationNameIn ){
        id = idIn;
        themeID = themeNameIn;
        animationID = animationNameIn;
      }

    }

public class AvatarSaver : State
{


  public AvatarData[] avatars;
  public int activeAvatar;

  public BrushHolder brushHolder;
  public Themes themes;
  public Animations animations;

 
  public override void WhileLiving(float v){
    numberStates = avatars.Length;
    currentState = activeAvatar;
  }

  public override void OnLive(){
    avatars = new AvatarData[9];




    for(int i = 0; i < avatars.Length; i++ ){ 

      string avatarFileName = "/AVAS/AVA_" + i +".ava";

      for( int j = 0; j < brushHolder.brushes.Length; j++ ){
        string fullName = "/DNA/" + brushHolder.brushes[j].name + "_" + i + ".dna";
        print( Application.streamingAssetsPath  +fullName );

        if (System.IO.File.Exists(Application.streamingAssetsPath  +fullName)){

          print("IT EXITS");
        }else{
          print("hello");
          Saveable.Save(brushHolder.brushes[j].particles,"DNA/"+brushHolder.brushes[j].name + "_" + i ); 

        }

      } 


      print( "fullName:  " + Application.streamingAssetsPath  +avatarFileName);
      if (System.IO.File.Exists(Application.streamingAssetsPath  +avatarFileName)){
        print("it exists");
      //do stuff

      
        Debug.Log("loading from lodabale");
        BinaryFormatter bf = new BinaryFormatter();
        FileStream stream = File.OpenRead(Application.streamingAssetsPath  + avatarFileName);
     
        avatars[i]  = bf.Deserialize(stream) as AvatarData;
       
        stream.Close();

      
      }else{
        print( "it doesn't exist");
        avatars[i] = new AvatarData(1, 0 , 0 ); 
        Save(i);
      }


    }
    Load(avatars[0]);
  }




  public override void horizontalSwipe( float val ){

    Save();

    if( val < 0 ){
     activeAvatar ++;
     activeAvatar %= avatars.Length; 
   }else{
     activeAvatar --;
     if(activeAvatar < 0 ){ activeAvatar += avatars.Length; }
   }

   Load();


  }


  public override void Deactivate(){}



  public void Save( int i ){
    int tActiveAvatar = activeAvatar;
    activeAvatar = i;
    Save();
    activeAvatar = tActiveAvatar;
  }


  public void Save(){

        float saveDataString = activeAvatar;

        //First save out all brushes
        //Second save out the actual avatar data with pointers towards this brush data
        List<string> brushesToSave = new List<string>();


        for( int i = 0; i < brushHolder.brushes.Length; i++ ){
        
          
            string fileName = brushHolder.brushes[i].name + "_" +saveDataString;

            print( fileName );

            brushesToSave.Add( brushHolder.brushes[i].name + "_" +saveDataString );
            Saveable.Save(brushHolder.brushes[i].particles,"DNA/"+fileName); 
      
        }

      AvatarData a = new AvatarData( activeAvatar , themes.activeTheme , animations.activeAnimation );

      string avatarFileName = "/AVAS/AVA_" + activeAvatar +".ava";

      SaveOut( a , avatarFileName );

    }

    public void SaveOut( AvatarData a , string fileName ){



      BinaryFormatter bf = new BinaryFormatter();
      FileStream stream = new FileStream(Application.streamingAssetsPath + fileName,FileMode.Create);

      bf.Serialize(stream,a);

      stream.Close();

    }




    public void Load(){

      string avatarFileName = "/AVAS/AVA_" + activeAvatar +".ava";
      
      if( File.Exists(Application.streamingAssetsPath  + avatarFileName )){
      
        Debug.Log("loading from lodabale");
        BinaryFormatter bf = new BinaryFormatter();
        FileStream stream = File.OpenRead(Application.streamingAssetsPath  + avatarFileName);
     
        AvatarData ad  = bf.Deserialize(stream) as AvatarData;
        Load( ad );
       
        stream.Close();

      }else{
        Debug.Log("Why would you load something that doesn't exist?!??!?");
      }

    }

    public void Load(AvatarData data){



      for( int i=0; i< brushHolder.brushes.Length; i++){
        string fileName = brushHolder.brushes[i].name + "_" + data.id;

        print( fileName );
        Saveable.Load( brushHolder.brushes[i].particles , "DNA/" + fileName );
      }

      themes.activeTheme = data.themeID;
      themes.SetActiveTheme();

      animations.activeAnimation = data.animationID;
      animations.SetActiveAnimation();


    }
}
