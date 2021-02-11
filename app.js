//jshint esversion:6
require('dotenv').config();
const express = require("express");
const bodyParser = require("body-parser");
const ejs = require("ejs");
const mongoose = require("mongoose");
const session = require('express-session');
const passport = require("passport");
const request = require("request");
const https =require("https");
const passportLocalMongoose = require("passport-local-mongoose");
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const findOrCreate = require('mongoose-findorcreate');

const app = express();

app.use(express.static("public"));
app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({
  extended: true
}));

app.use(session({
  secret: "Our little secret.",
  resave: false,
  saveUninitialized: false
}));

app.use(passport.initialize());
app.use(passport.session());

mongoose.connect("mongodb://localhost:27017/dras", {useNewUrlParser: true});
mongoose.set("useCreateIndex", true);

const userSchema = new mongoose.Schema ({
  email: String,
  password: String,
  googleId: String,
  perference: String,
  facilityType:String,
  connectedLoad:String,
  siteLoaction:String,
  Temp:String,
  SiteGeneration:String,
});

userSchema.plugin(passportLocalMongoose);
userSchema.plugin(findOrCreate);

const User = new mongoose.model("User", userSchema);
const siteTemp=User.SiteLocation
passport.use(User.createStrategy());

passport.serializeUser(function(user, done) {
  done(null, user.id);
});

passport.deserializeUser(function(id, done) {
  User.findById(id, function(err, user) {
    done(err, user);
  });
});

passport.use(new GoogleStrategy({
    clientID: process.env.CLIENT_ID,
    clientSecret: process.env.CLIENT_SECRET,
    callbackURL: "http://localhost:3000/auth/google/secrets",
    userProfileURL: "https://www.googleapis.com/oauth2/v3/userinfo"
  },
  function(accessToken, refreshToken, profile, cb) {
    console.log(profile);

    User.findOrCreate({ googleId: profile.id }, function (err, user) {
      return cb(err, user);
    });
  }
));

app.get("/", function(req, res){
  res.render("home");
});

app.get("/auth/google",
  passport.authenticate('google', { scope: ["profile"] })
);

app.get("/auth/google/secrets",
  passport.authenticate('google', { failureRedirect: "/login" }),
  function(req, res) {
    // Successful authentication, redirect to secrets.
    res.redirect("/secrets");
  });

app.get("/login", function(req, res){
  res.render("login");
});

app.get("/register", function(req, res){
  res.render("register");
});

app.get("/secrets", function(req, res){
  User.find({"secret": {$ne: null}}, function(err, foundUsers){
    if (err){
      console.log(err);
    } else {
      if (foundUsers) {
        res.render("secrets", {usersWithSecrets: foundUsers});
      }
    }
  });
});

app.get("/preferences", function(req, res){
  if (req.isAuthenticated()){

    //code for weather temperature
     

    //for redirecting to preferences page.
    res.render("preferensces");
   } else {
    res.redirect("/login");
  }
});

app.post("/preferences", function(req, res){
  const prefer_1 = req.body.preference;

//Once the user is authenticated and their session gets saved, their user details are saved to req.user.
  // console.log(req.user.id);

  User.findById(req.user.id, function(err, foundUser){
    if (err) {
      console.log(err);
    } else {
      if (foundUser) {
        foundUser.preference = prefer_1;
        foundUser.save(function(){
          res.redirect("/preferences");
        });
      }
    }
  });
});

app.get("/fillup", function(req, res){
  if (req.isAuthenticated()){
    res.render("fillup");
  } else {
    res.redirect("/login");
  }
});


app.get("/logout", function(req, res){
  req.logout();
  res.redirect("/");
});

app.post("/register", function(req, res){

  User.register({username: req.body.username}, req.body.password, function(err, user){
    if (err) {
      console.log(err);
      res.redirect("/register");
    } else {
      passport.authenticate("local")(req, res, function(){
        res.redirect("/fillup");
      });
    }
  });

});
 
app.post("/login", function(req, res){

  const user = new User({
    username: req.body.username,
    password: req.body.password
  });

  req.login(user, function(err){
    if (err) {
      console.log(err);
    } else {
      passport.authenticate("local")(req, res, function(){
        res.redirect("/preferences");
      });
    }
  });

});
 

// app.post("/fillup", function(req, res){

//   User.register({username: req.body.username}, req.body.password, function(err, user){
//     if (err) {
//       console.log(err);
//       res.redirect("/register");
//     } else {
//       passport.authenticate("local")(req, res, function(){
//         res.redirect("/preferences");
//       });
//     }
//   });

// });

app.post("/fillup", function(req, res){
  const connected_Load =req.body.ConnectedLoad;
  const facility_Type = req.body.FacilityType;
  const site_location= req.body.SiteLocation;

//Once the user is authenticated and their session gets saved, their user details are saved to req.user.
  // console.log(req.user.id);

  User.findById(req.user.id, function(err, foundUser){
    if (err) {
      console.log(err);
    } else {
      if (foundUser) {
        foundUser.connectedLoad = connected_Load;
        foundUser.facilityType = facility_Type;
        foundUser.site_location = site_location;
        foundUser.save(function(){
          res.redirect("/preferences");
        });
      }
    }
  });
  //for email signup for notification
  var firstName = connected_Load;
  var seconedName = site_location ;
  var email = req.body.email;
  const data = {
      members: [
          {
          email_address: email,
          status: subscribed,
          merge_fields: {
              Fname: firstName,
              Lname: seconedName
          }
        }
      ]
  };
  const jsonData =JSON.stringify(data);
  const url = "https://us10.api.mailchimp.com/3.0/lists/1effbef8be";
  const options = {
      method :"POST",
      auth: "shivam:2acb72b3386bf36a83610c2c0e87c923-us10"
  }
  const request= https.request(url,options,function(response){
       response.on("data",function(data){
           if(response.statusCode==200){
         
           res.sendFile(__dirname+"/success.html");  
        }
         else{
          
           res.sendFile(__dirname+"/success.html");  
         }
           console.log(JSON.parse(data));
       })
  })

 request.write(jsonData);
 request.end();
     
 });
//  app.post("/faliure",function(req,res){
//      res.redirect("/");




app.listen(3000, function() {
  console.log("Server started on port 3000.");
});
