//
//  SignUpView.swift
//  NutriHealth
//
//  Created by apple on 3/10/21.
//

import SwiftUI
import Parse
//This is the Sign up page

struct SignUpView: View
{
    @StateObject var viewRouter = ViewRouter()
    
    @State var username: String = ""
    @State var password: String = ""
    @State var heightft: String = ""
    @State var heightin: String = ""
    @State var heightConverted: Int = 0
    @State var weight: String = ""
    @State var hidden: Bool = false
    @State var age:String = ""
    @State var gender: String = ""
    @State var activityLevel: String = ""
    @State var fitnessGoals: String = ""
    @State var desiredPoundsLoss: String = ""
    @State var restingMetabolicRate: Double = 0.0
    @State var maintenanceCalories: Double = 0.0
    @State var recommendedCalories: Double = 0.0
    @State var recommendedProtein: Double = 0.0
    @State var recommendedFat: Double = 0.0
    @State var recommendedCarbs: Double = 0.0
    @State var bmi: Double = 0.0
    @State var recoMsg: String = ""
 
    var body: some View {
        VStack{
            Header()
            ScrollView(.vertical){
                VStack(alignment:.leading){
                    Username(username: $username)
                    Password(password: $password, hidden: $hidden)
                    Age(age: $age)
                    Height(heightft: $heightft.onChange(BMIPoundLossRecommendation), heightin: $heightin.onChange(BMIPoundLossRecommendation))
                    Weight(weight: $weight.onChange(BMIPoundLossRecommendation))
                    Gender(gender: $gender.onChange(BMIPoundLossRecommendation))
                    ActivityLevels(activityLevel: $activityLevel)
                    if(self.bmi != 0.0){
                        Text("\(self.recoMsg)")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(width: 375, height: 79)
                            .padding()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                                    .padding()
                            )
                    }
                    FitnessGoals(fitnessGoals: $fitnessGoals)
                    DesiredPoundsLoss(desiredPoundsLoss: $desiredPoundsLoss)
                }
                //SignUp button
                Button(action: {
                    self.createNewUser()
                    viewRouter.currentPage = .page2
                    
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 360, height: 51)
                        .background(Color.blue)
                        .cornerRadius(100.0)
                    .padding()
                }
            }
        }
        
    }
    
    func createNewUser(){
        print("creating new user...")
        let user = PFUser()
        user.username = self.username
        user.password = self.password

        user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
              let errorString = error.localizedDescription
              print(errorString)
            } else {
                print("Created user \(String(describing: user.username))")
                createPersonalModel(user: user)
            }
        }
    }
    
    func createPersonalModel(user: PFUser){
        print("Creating new personal model for \(user.username ?? "test")...")
        
        heightConverted = ((self.heightft as NSString).integerValue * 12) + (self.heightin as NSString).integerValue
        
        self.calculateRecommendations()
//        self.BMIPoundLossRecommendation()
        
        let personalModel = PFObject(className: "PersonalModel")
        personalModel.setObject(user.username!, forKey: "username")
        personalModel.setObject(self.age, forKey: "age")
        personalModel.setObject(self.heightConverted, forKey: "height")
        personalModel.setObject((self.weight as NSString).integerValue, forKey: "weight")
        personalModel.setObject(self.gender, forKey: "gender")
        personalModel.setObject(self.activityLevel, forKey: "activityLevel")
        personalModel.setObject(self.fitnessGoals, forKey: "fitnessGoals")
        personalModel.setObject(self.desiredPoundsLoss, forKey: "desiredPoundsLoss")
        personalModel.setObject(self.bmi, forKey: "bmi")
        personalModel.setObject(self.restingMetabolicRate, forKey: "restingMetabolicRate")
        personalModel.setObject(self.maintenanceCalories, forKey: "maintenanceCalories")
        personalModel.setObject(self.recommendedCalories, forKey: "recommendedCalories")
        personalModel.setObject(self.recommendedProtein, forKey: "recommendedProtein")
        personalModel.setObject(self.recommendedFat, forKey: "recommendedFat")
        personalModel.setObject(self.recommendedCarbs, forKey: "recommendedCarbs")
        personalModel.setObject(user, forKey: "user")

        personalModel.saveInBackground{
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
              let errorString = error.localizedDescription
              print(errorString)
            } else {
                print("Personal model for \(String(describing: user.username)) created")
            }
        }
    }
    
    func BMIPoundLossRecommendation(to Value: String) // THIS NEEDS TO BE DISPLAYED IN BETWEEN "ACTIVE" & "FITNESS GOALS"
    {
        heightConverted = ((self.heightft as NSString).integerValue * 12) + (self.heightin as NSString).integerValue
        self.bmi = ((self.weight as NSString).doubleValue / Double(self.heightConverted) / Double(self.heightConverted) * 703).roundTo(places: 1)

        if (self.bmi < 18.5){
            self.recoMsg = "You have an UNDERWEIGHT weight status. You are recommended to GAIN weight."
            print("You have an UNDERWEIGHT weight status. You are recommended to GAIN weight.")
        }
        else if (self.bmi >= 18.5) && (self.bmi < 25)
        {
            self.recoMsg = "You have a NORMAL weight status. You are recommended to MAINTAIN fit level."
            print("You have a NORMAL weight status. You are recommended to MAINTAIN fit level.")
        }
        else if (self.bmi >= 25) && (self.bmi < 30)
        {
            self.recoMsg = "You have a OVERWEIGHT weight status. You are recommended to LOSE weight."
            print("You have a OVERWEIGHT weight status. You are recommended to LOSE weight.")
        }
        else if (self.bmi >= 25) && (self.bmi < 30)
        {
            self.recoMsg = "You have a OBESE weight status. You are HIGHLY recommended to LOSE weight."
            print("You have a OBESE weight status. You are HIGHLY recommended to LOSE weight.")
        }
    }
    
    func calculateRecommendations() {
        var activityMultiplier: Double = 0.0
        
        if activityLevel == "inactive" {
            activityMultiplier = 1.2
        }
        else if activityLevel == "somewhatActive" {
            activityMultiplier = 1.3
        }
        else if activityLevel == "active" {
            activityMultiplier = 1.5
        }
        else { //very active
            activityMultiplier = 1.7
        }
        if self.gender == "male" {
            let weightFactor = 6.2 * (self.weight as NSString).doubleValue
            let heightFactor = 12.7 * Double(self.heightConverted)
            let ageFactor = 6.76 * Double(self.age)!
            self.restingMetabolicRate = 66 + weightFactor + heightFactor - ageFactor
        }
        else if self.gender == "female" {
            let weightFactor = 4.35 * (self.weight as NSString).doubleValue
            let heightFactor = 4.7 * Double(self.heightConverted)
            let ageFactor = 4.7 * Double(self.age)!
            self.restingMetabolicRate = 655 + weightFactor + heightFactor - ageFactor
        }
        self.maintenanceCalories = self.restingMetabolicRate * activityMultiplier
        
        if (self.desiredPoundsLoss == "5-10 pounds") && (self.fitnessGoals == "loseWeightGainMuscle") {
            self.recommendedCalories = self.maintenanceCalories - (self.maintenanceCalories * 0.1).roundTo(places: 1)
            self.recommendedProtein = ((self.weight as NSString).doubleValue).roundTo(places: 1)
            self.recommendedFat = ((self.weight as NSString).doubleValue * 0.4).roundTo(places: 1)
            self.recommendedCarbs = ((self.recommendedCalories - (self.recommendedProtein * 4) + (self.recommendedFat * 9)) / 4).roundTo(places: 1)
        }
        
        else if (self.desiredPoundsLoss == "15-25 pounds") && (self.fitnessGoals == "loseWeightGainMuscle") {
            self.recommendedCalories = (self.maintenanceCalories - (self.maintenanceCalories * 0.15)).roundTo(places: 1)
            self.recommendedProtein = ((self.weight as NSString).doubleValue * 0.8).roundTo(places: 1)
            self.recommendedFat = ((self.weight as NSString).doubleValue * 0.4).roundTo(places: 1)
            self.recommendedCarbs = ((self.recommendedCalories - (self.recommendedProtein * 4) + (self.recommendedFat * 9)) / 4).roundTo(places: 1)
        }
        
        else if (self.desiredPoundsLoss == "30+") && (self.fitnessGoals == "loseWeightGainMuscle") { //30+ lbs
            self.recommendedCalories = (self.maintenanceCalories - (self.maintenanceCalories * 0.2)).roundTo(places: 1)
            self.recommendedProtein = ((self.weight as NSString).doubleValue * 0.6).roundTo(places: 1)
            self.recommendedFat = ((self.weight as NSString).doubleValue * 0.4).roundTo(places: 1)
            self.recommendedCarbs = ((self.recommendedCalories - (self.recommendedProtein * 4) + (self.recommendedFat * 9)) / 4).roundTo(places: 1)
        }
        
        else if self.fitnessGoals == "maintainFitness" {
            self.recommendedCalories = (self.maintenanceCalories).roundTo(places: 1)
            self.recommendedProtein = ((self.weight as NSString).doubleValue).roundTo(places: 1)
            self.recommendedFat = ((self.weight as NSString).doubleValue * 0.4).roundTo(places: 1)
            self.recommendedCarbs = ((self.recommendedCalories - (self.recommendedProtein * 4) + (self.recommendedFat * 9)) / 4).roundTo(places: 1)
        }
        
        else if self.fitnessGoals == "gainWeightGainMuscle" {
            self.recommendedCalories = (self.maintenanceCalories * 1.15).roundTo(places: 1)
            self.recommendedProtein = ((self.weight as NSString).doubleValue).roundTo(places: 1)
            self.recommendedFat = ((self.weight as NSString).doubleValue * 0.4).roundTo(places: 1)
            self.recommendedCarbs = ((self.recommendedCalories - (self.recommendedProtein * 4) + (self.recommendedFat * 9)) / 4).roundTo(places: 1)
        }
    }
}



struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(viewRouter: ViewRouter())
    }
}

struct Username: View {
    @Binding var username:String
    var body: some View {
        Group{
            Text("Enter Username").padding(.leading)
            TextField("Username", text: $username)
                .padding()
                .frame(width: 360, height: 51)
                .background(Gray1)
                .cornerRadius(8.0)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Gray2, lineWidth: 1))
                .padding([.leading, .trailing])
        }
    }
}

struct Header: View {
    var body: some View {
        HStack(alignment: .top){
            Text("Let's create an account for you.").font(.largeTitle).fontWeight(.semibold).padding()
            Spacer()
            Image("dumbbell")
                .resizable()
                .frame(width: 100.0, height: 100.0)
                .scaledToFit()
                .padding()
        }
    }
}

struct Password: View {
    @Binding var password:String
    @Binding var hidden:Bool
    var body: some View {
        Group{
            Text("Create Password").padding(.leading)
            ZStack {
                HStack {
                    if self.hidden {
                        TextField("Password", text: $password)
                            .padding()
                            .frame(width: 360, height: 51)
                            .background(Gray1)
                            .cornerRadius(8.0)
                    } else {
                        SecureField("Password", text: $password)
                            .padding()
                            .frame(width: 360, height: 51)
                            .background(Gray1)
                            .cornerRadius(8.0)
                    }
                }.padding([.leading, .trailing]) // HStack
                Button(action: {self.hidden.toggle()})
                {
                    Image(systemName: self.hidden ? "eye.fill": "eye.slash.fill").foregroundColor((self.hidden == true) ? Color.green : Color.secondary)
                }.offset(x: 150.0, y:0.0)
            } // ZStack
        }
    }
}

struct Height: View {
    @Binding var heightft:String
    @Binding var heightin:String
    var body: some View {
        Group{
            Text("What is your height?").padding(.leading)
            HStack{
                TextField("0", text: $heightft)
                    .padding()
                    .frame(width: 100, height: 51)
                    .keyboardType(.numberPad)
                    .background(Gray1)
                    .cornerRadius(8.0)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Gray2, lineWidth: 1))
                    .padding([.leading, .trailing])
                Text("ft").padding()
                TextField("0", text: $heightin)
                    .padding()
                    .keyboardType(.numberPad)
                    .frame(width: 100, height: 51)
                    .background(Gray1)
                    .cornerRadius(8.0)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Gray2, lineWidth: 1))
                    .padding([.leading, .trailing])
                Text("in").padding()
            }
        }
    }
}

struct Weight: View {
    @Binding var weight: String
    var body: some View {
        Group{
            Text("How much do you weigh?").padding(.leading)
            HStack{
                TextField("0", text: $weight)
                    .padding()
                    .frame(width: 300, height: 51)
                    .keyboardType(.numberPad)
                    .background(Gray1)
                    .cornerRadius(8.0)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Gray2, lineWidth: 1))
                    .padding([.leading, .trailing])
                Text("lb").padding()
            }
        }
    }
}

struct Age: View {
    @Binding var age: String
    var body: some View {
        Group{
            Text("How old are you?").padding(.leading)
            TextField("Age", text: $age)
                .padding()
                .frame(width: 360, height: 51)
                .keyboardType(.numberPad)
                .background(Gray1)
                .cornerRadius(8.0)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Gray2, lineWidth: 1))
                .padding([.leading, .trailing])
        }
    }
}

struct Gender: View {
    @Binding var gender: String
    var genders: [String] = ["male", "female"]
    var body: some View {
        Group{
            Text("Select Gender").padding(.leading)
            Picker("Gender", selection: $gender, content: {
                Text("Male").tag(genders[0])
                Text("Female").tag(genders[1])
            })
        }
    }
}

struct ActivityLevels: View {
    @Binding var activityLevel:String
    var levels: [String] = ["inactive", "somewhatActive", "active", "veryActive"]
    var body: some View {
        Group{
            Text("How active are you?").padding(.leading)
            Picker("Activity Level", selection: $activityLevel, content: {
                Text("Inactive").tag(levels[0])
                Text("Somewhat Active").tag(levels[1])
                Text("Active").tag(levels[2])
                Text("Very Active").tag(levels[3])
            })
        }
    }
}

struct FitnessGoals: View {
    @Binding var fitnessGoals:String
    var goals: [String] = ["loseWeightGainMuscle", "maintainFitness", "gainWeightGainMuscle"]
    var body: some View {
        Group{
            Text("What are your Fitness Goals?").padding(.leading)
            Picker("Fitness Goals", selection: $fitnessGoals, content: {
                Text("Lose Weight & Gain Muscle").tag(goals[0])
                Text("Maintain Fit Level").tag(goals[1])
                Text("Gain Weight & Gain Muscle").tag(goals[2])
            })
        }
    }
}

struct DesiredPoundsLoss: View {
    @Binding var desiredPoundsLoss:String
    var poundsOptions: [String] = ["5-10 pounds", "15-25 pounds", "30+"]
    var body: some View {
        Group{
            Text("If you chose the “Lose Weight & Gain Muscle” option above, how much pounds would you like to lose?").padding(.leading)
            Picker("Select Desired Pounds Loss", selection: $desiredPoundsLoss, content: {
                Text("5-10 pounds").tag(poundsOptions[0])
                Text("15-25 pounds").tag(poundsOptions[1])
                Text("30+ pounds").tag(poundsOptions[2])
            })
        }
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}




