{

    "bones": [
        {
            "name": "ChestBottom",
            "color1": "Blue",
            "color2": "Blue",
            "frequency": 40
        },
        {
            "name": "RightUpperArm",
            "color1": "Red",
            "color2": "Red",
            "frequency": 40
        },
        {
            "name": "RightForeArm",
            "color1": "Green",
            "color2": "Green",
            "frequency": 40
        }
    ],
    "master_bone": "ChestBottom",
    "special": {
        "bone": "ChestBottom",
        "orientation": "Front"
    },
    "constraints": [
        {
            "type": "COPY",
            "target": "RightHand",
            "source": "RightForeArm"
        },
        {
            "type": "COPY",
            "target": "LeftCollar",
            "source": "ChestTop"
        },
        {
            "type": "COPY",
            "target": "RightCollar",
            "source": "ChestTop"
        }
    ]
   "custom":{
        "config_name":"Right arm + chest"
    }
}
