import funkin.options.OptionCategory;

function postCreate() {
    // Look through the generated menu categories
    for (i in 0...mainOptionsMenu.categories.length) {
        var category = mainOptionsMenu.categories[i];
        
        // Match the exact name you gave your category in options.xml
        if (category.name == "Myths of Tubbyland") { 
            
            // Remove it from its original spot
            mainOptionsMenu.categories.splice(i, 1);
            
            // Force insert it back at the very top (index 0)
            mainOptionsMenu.categories.insert(0, category);
            
            break; // Stop searching once moved
        }
    }
}