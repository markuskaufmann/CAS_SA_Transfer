workspace "Physio integration layer project" {

    model {
        patient = person "Patient: in" "Patient der jeweiligen Physio Organisation" "Patient"
        therapeut = person "Therapeut: in" "Person, welche Physiotherapien leitet" "therapeut"
        admin = person "Administrator" 
        dataScientist = person "Data Scientist"
        planungssoftwareFile = softwareSystem "Planungssoftware File"
        planungssoftwarePull = softwareSystem "Planungssoftware Pull"
        planungssoftwarePush = softwareSystem "Planungssoftware Push"
        

        therapieFile = softwareSystem "Therapie File"

        enterprise "Physio Connect" {
            integrationsSchicht = softwareSystem "Integrations Schicht" "Schnittstelle für Planungssoftwaren und Fitnesstrackern" "mainSystem"

            app = softwareSystem "Mobile App"
            uebungsKatalog = softwareSystem "Uebungs Katalog"
        }

        # relationships between people and software systems
        integrationsSchicht -> patient "Erhält einladung für Therapie"
        patient -> integrationsSchicht "Registriert sich"

        admin -> integrationsSchicht "Administriert Personal und Uebungen"
        therapeut -> planungssoftwareFile "Plant Therapien" 
        therapeut -> planungssoftwarePush "Plant Therapien" 
        therapeut -> planungssoftwarePull "Plant Therapien" 
        therapeut -> therapieFile "Editiert" 
        dataScientist -> integrationsSchicht "Benutzt Daten"
        patient -> app "installiert app"


        # relationships to/from containers
        planungssoftwareFile -> therapieFile "Exportiert"
        integrationsSchicht -> planungssoftwarePull "Erhält Therapie via API aufruf"
        planungssoftwarePush -> integrationsSchicht "Published neue Therapien auf die Therapiesoftware"
        app -> integrationsSchicht "Sendet Session updates mit Messdaten"
        integrationsSchicht -> app "Sendet Therapien, Sessions und Uebungen"
        integrationsSchicht -> uebungsKatalog "Importiert Uebungen"
        integrationsSchicht -> therapieFile "importiert Uebungen"
        # relationships to/from components
    }

    views {
        systemlandscape "SystemLandscape" {
            include *
            autoLayout
        }

        systemcontext integrationsSchicht "IntegrationsSchicht" {
            include *
            animation {
                integrationsSchicht
                patient
            }
            autoLayout
        }

        container integrationsSchicht "Containers" {
        }

        styles {
            element "Person" {
                color #ffffff
                fontSize 22
                shape Person
            }
            element "Customer" {
                background #08427b
            }
            element "Bank Staff" {
                background #999999
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "mainSystem" {
                background #000000
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Mobile App" {
                shape MobileDeviceLandscape
            }
            element "Database" {
                shape Cylinder
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Failover" {
                opacity 25
            }
        }
    }
}