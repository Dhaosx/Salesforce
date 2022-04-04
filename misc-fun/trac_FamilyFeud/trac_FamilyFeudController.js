/**
 * Created by SimonSalvatore on 2021-08-30.
 */

({
    displayText: function (component, event, helper) {
        let field = event.getSource().getLocalId();
        let category = component.get('v.category');

        let getSound = $A.get('$Resource.Ding');
        let playSound = new Audio(getSound);
        playSound.play();

        switch (category) {
            case '1': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Broken - 29');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Ugly - 22');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Divorce - 18');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Sell/need money - 12');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Too much stuff - 10');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Family feud - 5');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Moving - 2');
                        break;
                    }
                }
                break;
            }
            case '2': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Church - 35');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Groceries/shopping - 24');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Laundry - 12');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Clean the house - 6');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Sleep in - 6');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Eat out - 4');
                        break;
                    }
                }
                break;
            }
            case '3': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Bathroom - 24');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Baby/child - 19');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Bad dream - 16');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Heard a noise - 13');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Hot/cold - 12');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Hungry/thirsty - 6');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Work - 4');
                        break;
                    }
                    case '8': {
                        component.set('v.eighthText', 'Itchy - 2');
                        break;
                    }
                }
                break;
            }
            case '4': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Spain - 38');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Mexico - 24');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'USA - 10');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Cuba - 10');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Argentina - 4');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Costa Rica - 3');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Chile - 3');
                        break;
                    }
                    case '8': {
                        component.set('v.eighthText', 'Colombia - 3');
                        break;
                    }
                    case '9': {
                        component.set('v.ninthText', 'Guatemala - 2');
                        break;
                    }
                }
                break;
            }
            case '5': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Sun/Beach Weather - 62');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Fire/Flame Throwers - 14');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Blow Dryers - 3');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Rain - 3');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Snowplow/Shovel - 3');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Drought - 2');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Snowballs - 2');
                        break;
                    }
                    case '8': {
                        component.set('v.eighthText', 'Peeing Dogs/Pee - 2');
                        break;
                    }
                }
                break;
            }
            case '6': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Job - 24');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Personality/Humor - 15');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Warranty/Guarantee - 14');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Heart/Character - 12');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Bank Account - 10');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Bod/Butt - 9');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Head of Hair - 3');
                        break;
                    }
                    case '8': {
                        component.set('v.eighthText', 'Brain - 2');
                        break;
                    }
                }
                break;
            }
            case '7': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Banana - 25');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Grapefruit - 22');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Strawberry - 19');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Apple - 15');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Melon - 3');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Peach - 2');
                        break;
                    }
                }
                break;
            }
            case '8': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Traffic - 38');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Woke up/left late - 26');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Car trouble/accident - 11');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Bus/train delay - 10');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Dropping off kids - 4');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Sick/medical emergency - 4');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Weather - 3');
                        break;
                    }  
                    case '8': {
                        component.set('v.eighthText', 'Hungover - 2');
                        break;
                    }
                }
                break;
            }
            case '9': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Meatball - 28');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Peas - 21');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Grape - 16');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Orange - 13');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Apple - 8');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Candy/gumball - 5');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Egg - 2');
                        break;
                    }  
                }
                break;
            }
            case '10': {
                switch (field) {
                    case '1': {
                        component.set('v.firstText', 'Rat/mouse - 37');
                        break;
                    }
                    case '2': {
                        component.set('v.secondText', 'Snake - 22');
                        break;
                    }
                    case '3': {
                        component.set('v.thirdText', 'Cockroach - 21');
                        break;
                    }
                    case '4': {
                        component.set('v.fourthText', 'Spider - 7');
                        break;
                    }
                    case '5': {
                        component.set('v.fifthText', 'Lizard - 3');
                        break;
                    }
                    case '6': {
                        component.set('v.sixthText', 'Dog - 3');
                        break;
                    }
                    case '7': {
                        component.set('v.seventhText', 'Alligator - 2');
                        break;
                    }
                    case '8': {
                        component.set('v.eighthText', 'Fish - 2');
                        break;
                    }  
                }
                break;
            }
        }
    },

    changeCategory: function (component, event) {
        let val = event.getSource().get('v.value');

        component.set('v.firstText','');
        component.set('v.secondText','');
        component.set('v.thirdText','');
        component.set('v.fourthText','');
        component.set('v.fifthText','');
        component.set('v.sixthText','');
        component.set('v.seventhText','');
        component.set('v.eighthText','');
        component.set('v.ninthText','');
        component.set('v.tenthText','');

        switch (val) {
            case '1': {
                component.set('v.categoryHeader','Name a reason you might get rid of an old family heirloom');
                component.set('v.category', '1');
                break;
            }
            case '2': {
                component.set('v.categoryHeader','Tell me something many people do just once a week');
                component.set('v.category', '2');
                break;
            }
            case '3': {
                component.set('v.categoryHeader','Name a reason a person might wake up at 2:00 in the morning');
                component.set('v.category', '3');
                break;
            }
            case '4': {
                component.set('v.categoryHeader','Name a country that speaks Spanish');
                component.set('v.category', '4');
                break;
            }
            case '5': {
                component.set('v.categoryHeader','Name something snowmen might have nightmares about');
                component.set('v.category', '5');
                break;
            }
            case '6': {
                component.set('v.categoryHeader','If there was a store that only sold husbands, most people would try to buy one with what?');
                component.set('v.category', '6');
                break;
            }
            case '7': {
                component.set('v.categoryHeader','Name a fruit you might eat in the morning');
                component.set('v.category', '7');
                break;
            }
            case '8': {
                component.set('v.categoryHeader','Name a reason you might be late for work');
                component.set('v.category', '8');
                break;
            }
            case '9': {
                component.set('v.categoryHeader','Name something you eat that might roll away if you dropped it on the floor');
                component.set('v.category', '9');
                break;
            } 
            case '10': {
                component.set('v.categoryHeader','Name something you would hate to find swimming around in your bathtub');
                component.set('v.category', '10');
                break;
            }
        }
    }
});