'use strict'

const { Model } = require('sequelize')

module.exports = (sequelize, DataTypes) => {
    class Article extends Model {
        /**
         * Helper method for defining associations.
         * This method is not a part of Sequelize lifecycle.
         * The `models/index` file will call this method automatically.
         */
        static associate() {
            // define association here
        }
    }

    Article.init(
        {
            title: {
                type: DataTypes.STRING,
                allowNull: false,
                set(value) {
                    // Trim user supplied titles to keep the stored value clean.
                    this.setDataValue('title', value ? value.trim() : value)
                },
                validate: {
                    notEmpty: {
                        msg: 'Title is required.'
                    },
                    len: {
                        args: [1, 255],
                        msg: 'Title must be 1-255 characters long.'
                    }
                }
            },
            body: {
                type: DataTypes.TEXT,
                allowNull: false,
                validate: {
                    notEmpty: {
                        msg: 'Body is required.'
                    }
                }
            },
            approved: {
                type: DataTypes.BOOLEAN,
                allowNull: false,
                defaultValue: false
            }
        },
        {
            sequelize,
            modelName: 'Article'
        }
    )

    return Article
}
