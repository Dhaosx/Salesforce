/**
 * Created by SimonSalvatore on 2021-08-30.
 */

({
    displayText: function (component, event, helper) {
        let field = event.getSource().getLocalId();

        //let getSound = $A.get('$Resource.Ding');
        //let playSound = new Audio(getSound);
        //playSound.play();

        switch (field) {
            case '1': {
                component.set('v.firstText', '"Here\'s looking at you kid"');
                break;
            }
            case '2': {
                component.set('v.secondText', 'Creators of “Casper” say this film\'s logo plagiarized one of their characters.');
                break;
            }
            case '3': {
                component.set('v.thirdText', 'This "trick or treat" movie cost $300,000 to make but grossed $70 million.');
                break;
            }
            case '4': {
                component.set('v.fourthText', 'The code in the Matrix comes from this type of food recipe');
                break;
            }
            case '5': {
                component.set('v.fifthText', 'A movie about baseball which features very little actual baseball and is more akin to a movie about statistics');
                break;
            }
            case '6': {
                component.set('v.sixthText', 'Movie Club has gone through this many weeks at Traction');
                break;
            }
            case '7': {
                component.set('v.seventhText', 'Currently one of the most disliked cross projects, despite the goal to help children struggling in school');
                break;
            }
            case '8': {
                component.set('v.eighthText', 'Jeremy, Josh, Catherine, Vlad and others were OGs on this project for a major bank.');
                break;
            }
            case '9': {
                component.set('v.ninthText', 'This group of lawyers dropped Traction after expecting a million dollar project to be done for less than half that amount.');
                break;
            }
            case '10': {
                component.set('v.tenthText', 'Many/most members of le514 have been part of some phase of this project at some point.');
                break;
            }
            case '11': {
                component.set('v.eleventhText', 'This project originally had Adam Gold as BSC, Simon Salvatore as a Developer, and Mercedes as a PM known as "the General".');
                break;
            }
            case '12': {
                component.set('v.twelfthText', 'When Amin originally Interned for Traction, he was almost flown out to the Philippines during this project.');
                break;
            }
            case '13': {
                component.set('v.thirteenthText', 'New Tractionites used to do this for fun to learn more about the culture in Traction.');
                break;
            }
            case '14': {
                component.set('v.fourteenthText', 'This weekly tradition used to have Tractionites of le514 bring forth passages which they found meaningful and share with the Squad.');
                break;
            }
            case '15': {
                component.set('v.fifteenthText', 'This yearly tradition used to see Tractionites gather together to end the fiscal year and compete in the Traction Olympics.');
                break;
            }
            case '16': {
                component.set('v.sixteenthText', 'Done at the end of Squad huddles to give a boost to the participants');
                break;
            }
            case '17': {
                component.set('v.seventeenthText', 'A new Non-Profit Squad named after a type of tree');
                break;
            }
            case '18': {
                component.set('v.eighteenthText', 'This type of shark is also the name of a new Squad in which former member of le514, Mercedes, has joined.');
                break;
            }
            case '19': {
                component.set('v.nineteenthText', 'Some still consider this a planet, others do not.');
                break;
            }
            case '20': {
                component.set('v.twentythText', 'This country has the most natural lakes.');
                break;
            }
            case '21': {
                component.set('v.twentyfirstText', 'Gouda cheese originated in this country.');
                break;
            }
            case '22': {
                component.set('v.twentySecondText', 'Someone who does not behave as you expect might be called this; you\'d also used this word for a pack of pandas');
                break;
            }
            case '23': {
                component.set('v.twentyThirdText', 'This unit of measurement tracks the speed of a computer mouse.');
                break;
            }
            case '24': {
                component.set('v.twentyForthText', 'The real name for the hashtag "#" symbol');
                break;
            }
            case '25': {
                component.set('v.twentyFifthText', 'This game, developed and release by Russians in 1984, featured falling blocks.');
                break;
            }
            case '26': {
                component.set('v.twentySixthText', 'He was the first video game character to be featured in a Macy\'s parade as a balloon.');
                break;
            }
            case '27': {
                component.set('v.twentySeventhText', 'A giant monkey who is known for throwing barrels at an Italian Plumber.');
                break;
            }
            case '28': {
                component.set('v.twentyEigthText', 'Inky, Pinky, Blinky and Clyde were the names of Ghosts in this game.');
                break;
            }
            case '29': {
                component.set('v.twentyNinethText', 'One of the best selling video game franchise of all time, it also went mobile and had people wandering the streets.');
                break;
            }
            case '30': {
                component.set('v.thirtythText', '"War has changed" were the first words spoken by this character in Metal Gear Solid 4');
                break;
            }
            case '31': {
                component.set('v.thirtyFirstText', 'This song was sung by Tractionites whenever Karaoke was involved.');
                break;
            }
            case '32': {
                component.set('v.thirtySecondText', 'Originally released in 1987, this song saw a resurgence in 2009 and has since hit over 1 billion views on YouTube.');
                break;
            }
            case '33': {
                component.set('v.thirtyThirdText', '"Don\'t want to be a fool for you, Just another player in your game for two, You may hate me but it ain\'t no lie"');
                break;
            }
            case '34': {
                component.set('v.thirtyFourthText', '"Little Monsters" is the name of this singers fanbase');
                break;
            }
            case '35': {
                component.set('v.thirtyFifthText', 'This singer is coming to the Montreal Bell Center on February 22nd for her "Future Nostalgia" tour');
                break;
            }
            case '36': {
                component.set('v.thirtySixthText', 'Goodness gracious, this song was released in 1958');
                break;
            }
            case '37': {
                component.set('v.thirtySeventhText', 'This drink was very popular with the Spanish speaking members of le514.');
                break;
            }
            case '38': {
                component.set('v.thirtyEighthText', 'This flakey breakfast pastry was the result of people forgetting to lock their machines.');
                break;
            }
            case '39': {
                component.set('v.thirtyNinethText', 'This pub is a popular drinking location which is just walking distance from the office.');
                break;
            }
            case '40': {
                component.set('v.fortythText', 'This type of computing is not featured in Salesforce, unless someone pranked you to change "Cloud Computing".');
                break;
            }
            case '41': {
                component.set('v.fortyFirstText', 'A former Tractionite sat at their computer waiting for this to finish, not realizing it was a prank.');
                break;
            }
            case '42': {
                component.set('v.fortySecondText', 'This drink, meaning "firewater", could often be spotted on Graham\'s desk.');
                break;
            }
                break;
        }
    }
});